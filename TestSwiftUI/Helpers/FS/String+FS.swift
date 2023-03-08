import Foundation
import AppKit
import Essentials

public extension String {
    var FS: FSstr {
        FSstr(path: self)
    }
}

public class FSstr {
    public let path: String
    
    public init(path: String ) {
        self.path = path
    }
    
    public var info: FSFileInfo {
        return FSFileInfo(obj: self)
    }
    
    private var fmDefault: FileManager { FileManager.default }
}

public extension FSstr {
    var exist: Bool {
        return fmDefault.fileExists(atPath: path)
    }
    
    func delete() -> R<()> {
        Result { try fmDefault.removeItem(atPath: path) }
    }
    
    func openWithAssociatedApp() {
        NSWorkspace.shared.open(path.asURL())
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
            NSWorkspace.shared.activateFileViewerSelecting([path.asURL()])
        } else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
        }
    }
    
    @discardableResult
    func deleteToTrash() -> R<()> {
        path.asURL()
            .FS
            .deleteToTrash()
    }
    
    @available(macOS 10.15, *)
    func openTerminalAt() { path.asURL().FS.openTerminalAt() }
    
    @available(macOS 10.15, iOS 9.0, *)
    func openUrlWithApp(appUrl: URL) {
        FS.openUrlWithApp([path.asURL()], appUrl: appUrl)
    }
    
    func delete(_ path: String) -> R<()> {
        Result { try fmDefault.removeItem(atPath: path) }
    }
}
