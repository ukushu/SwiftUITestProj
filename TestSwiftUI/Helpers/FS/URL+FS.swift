import Foundation
import Essentials
import AppKit

public extension URL {
    var FS: FSurl {
        FSurl(url: self)
    }
}

public class FSurl {
    public let url: URL
    
    public init(url: URL ) {
        self.url = url
    }
    
    public var info: FSUrlFileInfo {
        return FSUrlFileInfo(obj: self)
    }
    
    private var fmDefault: FileManager { FileManager.default }
}

public extension FSurl {
    var exist: Bool {
        return fmDefault.fileExists(atPath: url.path)
    }
    
    func showInFinder() {
        showInFinder(selectLastComponent: !info.isDirectory)
    }
    
    ///If you put folder's url - it will show in Finder content of this folder. |
    ///If you put file's url - it will show in Finder file's parent and select file there. |
    ///Will do nothing in case url is nil. |
    ///Will do nothing in case file/path does not exist.
    func showInFinder(selectLastComponent: Bool) {
        if selectLastComponent {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
    }
    
    @discardableResult
    func deleteToTrash() -> R<()> {
        let deletedObj: AutoreleasingUnsafeMutablePointer<NSURL?>? = nil
        
        return Result{ try fmDefault.trashItem(at: url, resultingItemURL: deletedObj ) }
//            .flatMap { _ in  deletedObj.asNonOptional }
//            .flatMap { $0.pointee.asNonOptional }
//            .map { $0 as URL }
    }
    
    @available(macOS 10.15, *)
    func openTerminalAt() {
        guard let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")
        else { return }
        
        NSWorkspace.shared.open([url], withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration() )
    }
    
    @available(macOS 10.15, iOS 9.0, *)
    func openUrlWithApp(appUrl: URL) {
        FS.openUrlWithApp([url], appUrl: appUrl)
    }
    
    func delete() -> R<()> {
        Result { try fmDefault.removeItem(atPath: url.path) }
    }
}
