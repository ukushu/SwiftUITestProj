/*
    MIT License

    Copyright (c) 2014 Sergiy Vynnychenko

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

import Foundation
import Essentials
import AppKit
import AsyncNinja

public class FSApp {
    public static var fmDefault: FileManager { FileManager.default }
    
    public static var home : URL { return fmDefault.homeDirectoryForCurrentUser }
    
    public static var executableUrl: URL? {
        Bundle.main
            .executablePath?
            .asURL()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
    
    public class func appFolder() -> URL {
        #if os(iOS)
        return fmDefault.urls(for: .documentDirectory, in: .userDomainMask).first!
        #elseif os(OSX)
        return try! applicationSupportFolderURL().get()
        #endif
    }
    
    public class func urlFor(file: String) -> URL {
        return appFolder().appendingPathComponent(file)
    }
    
    public class func resourcePath(_ file: String, ofType: String) -> String? {
        return Bundle.main.path(forResource: file, ofType: ofType)
    }
    
    public class func resourceURL(_ file: String, ofType: String) -> URL? {
        return Bundle.main.url(forResource: file, withExtension: ofType)
    }
    
    public class func appSupportRoot(in mask: FileManager.SearchPathDomainMask) -> URL {
        do {
            return try fmDefault.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: false)
        } catch {
            fatalError()
        }
    }
    
    public class func deleteFilesWith(prefix: String, at: URL? = nil) {
        let location = at ?? appFolder()
        let urls = location.getFiles()
        
        for url in urls {
            if url.lastPathComponent.hasPrefix(prefix) {
                url.FS.delete()
                    .onFailure {
                        print("Failed to delete file: \(url.path). \nError:\($0)" )
                    }
            }
        }
    }
}

extension FSApp {
    public class func applicationSupportFolderURL(in mask: FileManager.SearchPathDomainMask = .userDomainMask) -> R<URL> {
        return Result {
            try fmDefault.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: true)
        }
        .map { $0.appendingPathComponent(Bundle.main.bundleIdentifier!) }
        .flatMap { fullPath in
            Result {
                try fmDefault.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
            }
            .map{ _ in fullPath }
        }
    }
    
    public class func applicationSupportFolder() -> String {
        return try! applicationSupportFolderURL().get().absoluteString
    }
}

public class FS {
    public static var fmDefault: FileManager { FileManager.default }
    
    @available(*, deprecated, message: "use url.FS.exist instead" )
    public class func exist(_ url: URL?) -> Bool {
        guard let url = url else { return false }
        
        return exist(url.path)
    }
    
    @available(*, deprecated, message: "use path.FS.exist instead" )
    public class func exist(_ path: String?) -> Bool {
        guard let path = path else { return false }
        
        return fmDefault.fileExists(atPath: path)
    }
    
    @discardableResult
    public class func mkdir(_ url : URL) -> R<()> {
        mkdir(url.path)
    }
    
    @discardableResult
    public class func mkdir(_ path : String) -> R<()> {
        if exist(path) {
            return .wtf("Dir already exist: \(path)")
        }
        
        return Result {
            try fmDefault.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        .flatMapError{ .wtf("Can't create dir at path : \(path). \nError: \($0.localizedDescription)")}
    }
    
    public class func copy(_ fromUrl: URL, toUrl: URL, replace: Bool = false) -> R<()> {
        copy(fromUrl.path, toPath: toUrl.path, replace: replace)
    }
    
    public class func copy(_ fromPath: String, toPath: String, replace: Bool = false) -> R<()> {
        var result: R<()> = .success(())
        
        // delete destination file if it exist
        if replace && fmDefault.fileExists(atPath: toPath) {
            result = delete(toPath)
        }
        
        return result.flatMap { Result { try fmDefault.copyItem(atPath: fromPath, toPath: toPath) } }
    }
    
    public class func move(_ fromUrl: URL, toUrl: URL, replace: Bool = false) -> R<()> {
        move(fromUrl.path, toPath: toUrl.path, replace: replace)
    }
    
    public class func move(_ fromPath: String, toPath: String, replace: Bool = false) -> R<()> {
        var result: R<()> = .success(())
        
        if replace && exist(toPath) {
            result = delete(toPath)
        }
        
        return result.flatMap { Result { try fmDefault.moveItem(atPath: fromPath, toPath: toPath) } }
    }
    
    @available(*, deprecated, message: "use url.FS.delete() instead" )
    public class func delete(_ url: URL) -> R<()> { delete(url.path) }
    
    @available(*, deprecated, message: "use path.FS.delete() instead" )
    public class func delete(_ path: String) -> R<()> {
        Result { try fmDefault.removeItem(atPath: path) }
    }
    
    @available(*, deprecated, message: "use url.FS.deleteToTrash() instead" )
    @discardableResult
    public class func deleteToTrash(_ url : URL) -> R<()> {
        let deletedObj: AutoreleasingUnsafeMutablePointer<NSURL?>? = nil
        
        return Result{ try fmDefault.trashItem(at: url, resultingItemURL: deletedObj ) }
//            .flatMap { _ in  deletedObj.asNonOptional }
//            .flatMap { $0.pointee.asNonOptional }
//            .map { $0 as URL }
    }
    
    @available(*, deprecated, message: "use path.FS.deleteToTrash() instead" )
    @discardableResult
    public class func deleteToTrash(_ path : String) -> R<()> {
        deleteToTrash(URL(fileURLWithPath: path))
    }
    
    
    @available(*, deprecated, message: "use url.FS.showInFinder() instead" )
    public class func showInFinder(url: URL?) {
        showInFinder(url: url, selectLastComponent: !(url?.isDirectory ?? true) )
    }
    
    @available(*, deprecated, message: "use url.FS.showInFinder() instead" )
    public class func showInFinder(url: URL?, selectLastComponent: Bool) {
        guard let url = url else { return }
        
        if selectLastComponent {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
    }
    
    @available(*, deprecated, message: "use path.FS.showInFinder() instead" )
    public class func showInFinder(path: String?) {
        showInFinder(url: path?.asURL())
    }
    
    @available(*, deprecated, message: "use path.FS.showInFinder() instead" )
    public class func showInFinder(path: String?, selectLastComponent: Bool) {
        showInFinder(url: path?.asURL(), selectLastComponent: selectLastComponent)
    }
    
    /// returns all of URLs from children folders + of all subdirs files
    public class func contentOfDirectory(url: URL, includingSubdir: Bool) -> R<[URL]> {
        if includingSubdir {
            return .success( url.getFiles() )
        }
        
        return Result {
            try fmDefault
                        .contentsOfDirectory(at: url,
                                             includingPropertiesForKeys: nil,
                                             options: [.skipsHiddenFiles])
        }
    }
    
    ///Returns DIRECT CHILDS-FOLDERS
    public class func subDirectories(of url: URL) -> R<[URL]> {
        Result {
            try fmDefault
                        .contentsOfDirectory(at: url,
                                             includingPropertiesForKeys: nil,
                                             options: [.skipsHiddenFiles])
                        .filter(\.hasDirectoryPath)
        }
    }
    
    @available(*, deprecated, message: "use path.FS.openWithAssociatedApp() instead" )
    public class func openWithAssociatedApp(_ url: URL?) {
        if let url = url {
            openWithAssociatedApp(url.path)
        }
    }
    
    @available(*, deprecated, message: "use path.FS.openWithAssociatedApp() instead" )
    public class func openWithAssociatedApp(_ path: String) { NSWorkspace.shared.openFile(path) }
    
    @available(*, deprecated, message: "use url.FS.openTerminalAt() instead" )
    @available(macOS 10.15, *)
    public class func openTerminal(at url: URL?) {
        guard let url = url,
              let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Terminal")
        else { return }
        
        NSWorkspace.shared.open([url], withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration() )
    }
    
    @available(*, deprecated, message: "use url.FS.openUrlWithApp() instead" )
    @available(macOS 10.15, iOS 9.0, *)
    public class func openUrlWithApp(_ url: URL, appUrl: URL) {
        openUrlWithApp([url], appUrl:appUrl)
    }
    
    @available(macOS 10.15, iOS 9.0, *)
    public class func openUrlWithApp(_ urls: [URL], appUrl: URL) {
        NSWorkspace.shared.open(urls, withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration())
    }
    
    public class func openGetInfoWnd(for url: URL) {
        openGetInfoWnd(for: [url])
    }
    
    public class func openGetInfoWnd(for urls: [URL]) {
        let pBoard = NSPasteboard(name: NSPasteboard.Name(rawValue: "pasteBoard_\(UUID().uuidString )") )
        
        pBoard.writeObjects(urls as [NSPasteboardWriting])
        
        NSPerformService("Finder/Show Info", pBoard);
    }
}


@available(*, deprecated, message: "use FS or FSApp instead of FS_OLD")
public class FS_OLD {
    static var fmDefault: FileManager { FileManager.default }
    
    public static var home : URL { return fmDefault.homeDirectoryForCurrentUser }

    public class func urlFor(file: String) -> URL {
        return appFolder().appendingPathComponent(file)
    }
    
    public class func resourcePath(_ file: String, ofType: String) -> String? {
        return Bundle.main.path(forResource: file, ofType: ofType)
    }
    
    public class func resourceURL(_ file: String, ofType: String) -> URL? {
        return Bundle.main.url(forResource: file, withExtension: ofType)
    }
    
    public class func applicationSupportFolder() -> String {
        return applicationSupportFolderURL().absoluteString
    }
    
    public class func appFolder() -> URL {
        #if os(iOS)
        return fmDefault.urls(for: .documentDirectory, in: .userDomainMask).first!
        #elseif os(OSX)
        return applicationSupportFolderURL()
        #endif
    }
    
    public class func appSupportRoot(in mask: FileManager.SearchPathDomainMask) -> URL {
        do {
            return try fmDefault.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: false)
        } catch {
            fatalError()
        }
    }
    
    public class func applicationSupportFolderURL(in mask: FileManager.SearchPathDomainMask = .userDomainMask) -> URL {
        var appSupportURL: URL?
        do {
            appSupportURL = try fmDefault.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: mask, appropriateFor: nil, create: true)
        } catch _ as NSError {
            appSupportURL = nil
        }
        
        let fullPath = appSupportURL!.appendingPathComponent(Bundle.main.bundleIdentifier!)
        
        do {
            try fmDefault.createDirectory(at: fullPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch _ {
            print("BLA")
        }
        
        return fullPath
    }
    
    public class func mkdir(_ path : String) {
        if exist(path: path) {
            print("Dir already exist: \(path)")
            return
        }
        
        do {
            try fmDefault.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Can't create dir at path : \(path). \nError: \(error.localizedDescription)")
        }
    }
    
    public class func exist(_ url: URL) -> Bool {
        return exist(path: url.path)
    }
    
    public class func exist(path: String) -> Bool {
        return fmDefault.fileExists(atPath: path)
    }
    
    @discardableResult
    private class func copy(from: URL, to: URL, force: Bool = true) -> Bool {
        guard fmDefault.fileExists(atPath: from.path) else { return false }
        
        if force {
            FS_OLD.delete(to)
        }
        
        do {
            try fmDefault.copyItem(at: from, to: to)
        } catch _ {
            return false
        }
        
        return true
    }
    
    private class func copy(_ fromPath: String, toPath: String, force: Bool = true) -> Bool {
        // delete destination file if it exist
        if force {
            if fmDefault.fileExists(atPath: toPath) {
                do {
                    try fmDefault.removeItem(atPath: toPath)
                } catch _ {
                }
            }
        }
        
        do {
            try fmDefault.copyItem(atPath: fromPath, toPath: toPath)
            return true
        } catch _ {
            return false
        }
    }
    
    
    
    public static func copyAdv(from urlFrom: URL, to urlTo: URL, executor: Executor = .background) -> Future<()> {
        return promise(executor: executor) { promise in
            FS_OLD.copy(from: urlFrom, to: urlTo)
            promise.succeed()
        }
    }
    
    private class func move(_ fromPath: String, toPath: String, force: Bool = true) -> Bool {
        // delete destination file if it exist
        if force {
            if fmDefault.fileExists(atPath: toPath) {
                do {
                    try fmDefault.removeItem(atPath: toPath)
                } catch _ {
                }
            }
        }
        
        do {
            try fmDefault.moveItem(atPath: fromPath, toPath: toPath)
            return true
        } catch _ {
            return false
        }
    }
    
    @discardableResult
    private class func move(from: URL, to: URL, force: Bool = true) -> Bool {
        guard fmDefault.fileExists(atPath: from.path) else { return false }
        
        if force {
            FS_OLD.delete(to)
        }
        
        do {
            try fmDefault.moveItem(at: from, to: to)
        } catch _ {
            return false
        }
        
        return true
    }
    
    public static func moveAdv(from urlFrom: URL, to urlTo: URL, executor: Executor = .background) -> Future<()> {
        return promise(executor: executor) { promise in
            FS_OLD.move(from: urlFrom, to: urlTo)
            promise.succeed()
        }
    }
        
    public class func deleteFilesWith(prefix: String, at: URL? = nil) {
        let location = at ?? appFolder()
        let urls = location.getFiles()
        
        for url in urls {
            if url.lastPathComponent.hasPrefix(prefix) {
                delete(url, silent: false)
            }
        }
        
    }
    
    public class func deleteNew(_ url: URL) throws {
        try fmDefault.removeItem(atPath: url.path)
    }
    
    public class func delete(_ url: URL, silent: Bool = true) {
        delete(url.path, silent: silent)
    }
    
    public class func delete(_ path : String, silent: Bool = true) {
        if !silent {
            print("FS: going to delete file: \(path)")
        }
        
        do {
            try fmDefault.removeItem(atPath: path)
        } catch let error {
            if !silent {
                print("FS: cant delete \(path)")
                print(error)
            }
        }
    }
    
    public class func deleteToTrash(_ path: String, silent: Bool = true)  -> AutoreleasingUnsafeMutablePointer<NSURL?>? {
        return deleteToTrash(URL(fileURLWithPath: path), silent: silent )
    }
    
    public class func deleteToTrash(_ url : URL, silent: Bool = true) -> AutoreleasingUnsafeMutablePointer<NSURL?>?{
        let deletedObj: AutoreleasingUnsafeMutablePointer<NSURL?>? = nil
        
        if !silent {
            print("FS: going to move to trash : \(url.path)")
        }
        
        do {
            try fmDefault.trashItem(at: url, resultingItemURL: deletedObj )
        } catch let error {
            if !silent {
                print("FS: cant delete \(url.path)")
                print(error)
            }
        }
        
        return deletedObj
    }
    
    ///If you put folder's url - it will show in Finder content of this folder. |
    ///If you put file's url - it will show in Finder file's parent and select file there. |
    ///Will do nothing in case url is nil. |
    ///Will do nothing in case file/path does not exist.
    public class func showInFinder(url: URL?) {
        guard let url = url else { return }
        
        if url.isDirectory {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
        }
        else {
            showInFinderAndSelectLastComponent(of: url)
        }
    }
    
    public class func showInFinderAndSelectLastComponent(of url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    public class func contentOfDirectory(url: URL, withSubdirs: Bool ) -> [URL] {
        do {
            return try fmDefault.subpathsOfDirectory(atPath: url.path)
                            .map{ path in URL(fileURLWithPath: path) }
        } catch _ {
            print("Can't get dirs from: " + url.path)
        }
        
        return []
    }
    
    ///Returns DIRECT CHILDS-FOLDERS
    @available(macOS 10.11, iOS 9.0, *)
    public class func subDirectories(of url: URL) -> [URL] {
        if let res = try? fmDefault
                    .contentsOfDirectory(at: url,
                                         includingPropertiesForKeys: nil,
                                         options: [.skipsHiddenFiles])
                    .filter(\.hasDirectoryPath)
        {
            return res
        }

        return []
    }
    
    public class func openWithAssociatedApp(url: URL?) {
        if let url = url {
            NSWorkspace.shared.openFile(url.path)
        }
    }
    
    public class func openWithAssociatedApp(path: String) {
        NSWorkspace.shared.openFile(path)
    }
}
