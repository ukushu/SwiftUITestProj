import Foundation
import SwiftUI
import QuickLook
import QuickLookThumbnailing
import Darwin
import Essentials

public class FBCollectionCache {
    private static var cache: [String : FBCCacheItem] = [:]
    
    private static let timer = TimerCall(.continious(interval: 1)) {
        automaticCacheCleanup()
    }
    
    static func getCachedImg(path: String) -> FBCCacheItem? {
        let _ = FBCollectionCache.timer
        
        if let item = cache[path] {
            cache[path]?.updLastAccessDate()
            
            return item
        } else {
            cache[path] = FBCCacheItem(path: path)
        }
        
        return cache[path]
    }
    
    static func automaticCacheCleanup() {
        let countToLeave = 150
        
        if cache.count > countToLeave * 2 { //DO NOT CHANGE
            let oldCache = cache.count
            
            cache.sorted { $0.value.lastAccessDate < $1.value.lastAccessDate }
                .dropFirst(cache.count - countToLeave)
                .forEach {
                    cache[$0.key] = nil
                }
            
            print("cacheCleanup: \(oldCache) -> \(cache.count)")
        }
    }
    
    static func clearCache() {
        cache = [:]
    }
}

class FBCCacheItem {
    private(set) var thumbnail: NSImage? = nil
    private(set) var lastAccessDate: Date = Date.now
    private let path: String
    
    init(path: String) {
        self.path = path
        updateThumbnail()
    }
    
    func updateThumbnail() {
        DispatchQueue.global(qos: .background).async {
            self.thumbnail = imgThumbnailAdv(125, path: self.path)
        }
    }
    
    func updLastAccessDate() {
        self.lastAccessDate = Date.now
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

extension Dictionary where Key == String, Value == FBCCacheItem {
    var sizeInBytes: Int {
        class_getInstanceSize(FBCCacheItem.self) * self.count
    }
}
