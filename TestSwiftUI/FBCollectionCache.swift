import Foundation
import SwiftUI
import QuickLook
import QuickLookThumbnailing
import Darwin

public class FBCollectionCache {
    private static var cache: [String : FBCCacheItem] = [:]
    
    static func getCachedImg(path: String) -> FBCCacheItem? {
        if let img = cache[path] {
            return img
        }
        
        cache[path] = FBCCacheItem(path: path)
        
        
        
//        let cahceSizeBytes = class_getInstanceSize(FBCCacheItem.self) * cache.count
//        print("Cache size: \(cahceSizeBytes)")
        
        
        return cache[path]
    }
    
    static func clearCache() {
        cache = [:]
    }
}

class FBCCacheItem {
    private(set) var thumbnail: NSImage? = nil
    private(set) var date: Date = Date.now
    private let path: String
    
    init(path: String) {
        self.path = path
        updateThumbnail()
    }
    
    func updateThumbnail() {
        self.date = Date.now
        
        DispatchQueue.global(qos: .background).async {
            self.thumbnail = imgThumbnailAdv(125, path: self.path)
        }
    }
}


//////////////////////////////////
///HELPERS
/////////////////////////////////

fileprivate func imgThumbnailAdv(_ size: CGFloat, path: String) -> NSImage? {
    if path.FS.info.isDirectory {
        return path.FS.info.hiresQLThumbnail(size: size).wait().maybeSuccess ??
               path.FS.info.hiresIcon(size: Int(size))
    }
    
    let extensionsExceptions: [String]  = ["txt","docx","doc","pages","odt","rtf","tex","wpd","ltxd",
                                           "btxt","dotx","wtt","dsc","me","ans","log","xy","text","docm",
                                           "wps","rst","readme","asc","strings","docz","docxml","sdoc",
                                           "plain","notes","latex","utxt","ascii",
                                           
                                           "xlsx","patch","xls","xlsm","ods",
                                           
                                           "py","cs","swift","html","css", "fountain","gscript","lua",
                                           
                                           "markdown","md",
                                           "plist", "ips"
    ]
    
    if path.lowercased().hasSuffix(extensionsExceptions) {
        return path.FS.info.hiresQLThumbnail(size: size).wait().maybeSuccess ??
                path.FS.info.hiresIcon(size: Int(size))
    }
    
    return path.FS.info.hiresThumbnail(size: size)
}

extension NSImage{
    var pixelSize: NSSize?{
        if let rep = self.representations.first{
            let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            return size
        }
        return nil
    }
}


class IconCache {
    private static let musicIcon = NSImage(named: "MusicIcon")
    
    static func getIcon(path: String) -> NSImage? {
        if let mimeType = path.FS.info.mimeType, mimeType.conforms(to: .audio) {
            return musicIcon
        }
        
        return NSWorkspace.shared.icon(forFile: path)
    }
}


//func allocatedMem() {
//    let TASK_VM_INFO_COUNT = MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size
//
//    var vmInfo = task_vm_info_data_t()
//    var vmInfoSize = mach_msg_type_number_t(TASK_VM_INFO_COUNT)
//
//    let kern: kern_return_t = withUnsafeMutablePointer(to: &vmInfo) {
//            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                task_info(mach_task_self_,
//                          task_flavor_t(TASK_VM_INFO),
//                          $0,
//                          &vmInfoSize)
//                }
//            }
//
//    if kern == KERN_SUCCESS {
//        let usedSize = DataSize(bytes: Int(vmInfo.internal + vmInfo.compressed))
//        print("Memory in use (in bytes): %u", usedSize)
//    } else {
//        let errorString = String(cString: mach_error_string(kern), encoding: .ascii) ?? "unknown error"
//        print("Error with task_info(): %s", errorString);
//    }
//}
