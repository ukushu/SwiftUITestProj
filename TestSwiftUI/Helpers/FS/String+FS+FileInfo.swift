import Foundation
import Quartz
import QuickLook
import QuickLookThumbnailing
import Essentials
import AsyncNinja

public class FSFileInfo {
    private let obj: FSstr
    public var path: String { obj.path }
    
    public init(obj: FSstr) {
        self.obj = obj
    }
}

public extension FSFileInfo {
    var name: String { path.split(separator: "/").last?.asString() ?? "failedToGetName" }
    
    var isDirectory: Bool {
        var check: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &check) {
            return check.boolValue
        } else {
            return false
        }
    }
    
    @available(macOS 11.0, *)
    var mimeType: UTType? {
        guard let ext = self.path.split(separator: ".").last?.asString() else { return nil }
        
        let type = UTType(filenameExtension: ext)
        
        return type
    }
}

public extension FSFileInfo {
    var addedToFSDate: Date? {
        return getAttributes()["kMDItemDateAdded"] as? Date
    }
    
    var lastUseDate: Date? {
        return path.withCString {
            var statStruct = Darwin.stat()
            guard  stat($0, &statStruct) == 0 else { return nil }
            let lastRead = Date(
                timeIntervalSince1970: TimeInterval(statStruct.st_atimespec.tv_sec)
            )
            let lastWrite = Date(
                timeIntervalSince1970: TimeInterval(statStruct.st_mtimespec.tv_sec)
            )
            
            // If you want to include dir entry updates
//            let lastDirEntryChange = Date(
//                timeIntervalSince1970: TimeInterval(statStruct.st_ctimespec.tv_sec)
//            )
            
            return max(lastRead, lastWrite )
        }
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    
    var modificationDate: Date? {
        return attributes?[.modificationDate] as? Date
    }
    
    var fileSizeBytes: UInt64? {
        return attributes?[.size] as? UInt64
    }
    
    var fileSizeString: String? {
        if self.isDirectory {
            return nil
        }
        if let bytes = fileSizeBytes {
            return " - " + ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
        }
        
        return nil
    }
    
    var isHidden: Bool { path.contains("/.") }
    
    func getAttributes() -> [String : Any] {
        let attrItem = NSMetadataItem(url: path.asURL() )
        
        if let item = attrItem,
           let attributes = item.values(forAttributes: item.attributes) {
            return attributes
        }
        
        return [:]
    }
}

public extension FSFileInfo {
    var icon: NSImage {
        NSWorkspace.shared.icon(forFile: self.path)
    }
    
    func hiresIcon(size: CGFloat = 512) -> NSImage {
        hiresIcon(size: Int(size))
    }
    
    func hiresIcon(size: Int = 512) -> NSImage {
        NSWorkspace.shared.highResIcon(forPath: self.path, resolution: size)
    }
    
    func hiresThumbnail(size: CGFloat = 512) -> NSImage {
        hiresThumbnail(size: Int(size))
    }
    
    func hiresThumbnail(size: Int = 512) -> NSImage {
        let url: NSURL = NSURL(fileURLWithPath: self.path)
        
        let ref = QLThumbnailCreate ( kCFAllocatorDefault,
                                      url,
                                      CGSize(width: size, height: size),
                                      [ kQLThumbnailOptionIconModeKey: false ] as CFDictionary
        )
        
        guard let thumbnail = ref?.takeRetainedValue()
        else { return hiresIcon(size: size) }
        
        if let cgImageRef = QLThumbnailCopyImage(thumbnail) {
            let cgImage = cgImageRef.takeRetainedValue()
            return NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        }
        
        return hiresIcon(size: size)
    }
}

//////////////////
//HELPERS
/////////////////

fileprivate extension NSWorkspace {
    func highResIcon(forPath path: String, resolution: Int) -> NSImage {
        if let rep = self.icon(forFile: path)
            .bestRepresentation(for: NSRect(x: 0, y: 0, width: resolution, height: resolution), context: nil, hints: nil) {
            let image = NSImage(size: rep.size)
            image.addRepresentation(rep)
            return image
        }
        
        return self.icon(forFile: path)
    }
}

////////////////////////////////////////
// MOVE TO URL's FS
////////////////////////////////////////
public extension URL {
    func getImgThumbnail(_ size: CGFloat) -> NSImage? {
        let ref = QLThumbnailCreate ( kCFAllocatorDefault,
                                      self as NSURL,
                                      CGSize(width: size, height: size),
                                      [ kQLThumbnailOptionIconModeKey: false ] as CFDictionary
        )
        
        guard let thumbnail = ref?.takeRetainedValue()
        else { return nil }
        
        if let cgImageRef = QLThumbnailCopyImage(thumbnail) {
            let cgImage = cgImageRef.takeRetainedValue()
            return NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        }
        
        return nil
    }
}


fileprivate extension FSFileInfo {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
}


extension FSFileInfo {
    @available(macOS 10.15, *)
    func hiresQLThumbnail(size: CGFloat = 512) -> Future<NSImage> {
        return quickLookThumbnail(url: path.asURL(), type: .thumbnail, size: size)
    }
}


@available(macOS 10.15, *)
fileprivate func quickLookThumbnail(url: URL,
                                    type: QLThumbnailGenerator.Request.RepresentationTypes,
                                    size: CGFloat) -> Future<NSImage> {
    let size = CGSize(width: size, height: size)
    
    let request = QLThumbnailGenerator.Request(fileAt: url,
                                               size: size,
                                               scale: NSScreen.main?.backingScaleFactor ?? 1,
                                               representationTypes: type)
    request.iconMode = true
    
    return promise { promise in
        DispatchQueue.main.async {
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
                    if let error = error {
                        promise.fail(error)
                        return
                    }
                    
                    if let thumbnail = thumbnail {
                        promise.succeed(thumbnail.nsImage)
                    } else {
                        promise.fail( NSError(domain: "www", code: 666) )
                    }
                    
                    if !promise.isComplete {
                        promise.fail( NSError(domain: "www", code: 667) )
                    }
            }
        }
    }
}
