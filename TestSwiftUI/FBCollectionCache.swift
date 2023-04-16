import Foundation
import SwiftUI
import QuickLook
import QuickLookThumbnailing
import Darwin
import Essentials

public class FBCollectionCache {
    private static var cache: [String : FBCCacheItem] = [:]
    private static var metadata: [String : FBCCacheMeta] = [:]
    
    private static let timer = TimerCall(.continious(interval: 1)) {
        automaticCacheCleanup()
        automaticCacheCleanupMeta()
    }
    
    static func getFor(path: String) -> FBCCacheItem {
        let _ = FBCollectionCache.timer
        
        if let item = cache[path] {
            item.updLastAccessDate()
            return item
        }
        
        let newItem = FBCCacheItem(path: path)
        cache[path] = newItem
        
        return newItem
    }
    
    static func getMetaFor(path: String) -> RecentFile {
        if let item = metadata[path] {
            return item.model
        }
        
        let newItem = FBCCacheMeta(path: path)
        metadata[path] = newItem
        
        return newItem.model
    }
    
    static func automaticCacheCleanup() {
//        let oldCache = cache.count
        
        let minCountToLeave = 18
        let countToLeave = 700
        let countToDoCleanup = Int( 1.2 * Double(countToLeave) )
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-20))
        
        //clean older than maxTimeSec
        let cashSortedNewFirstly = cache
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
        
        cashSortedNewFirstly
            .dropFirst(minCountToLeave)
            // clean older than maxTime. Checked - correctly works
            .filter { maxTime > $0.value.lastAccessDate }
            .forEach {
//                print( cache[$0.key]!.lastAccessDate.string(withFormat: "ss.sss") )
                cache.remove(key: $0.key)
            }
        
        if cache.count > countToDoCleanup {
            cashSortedNewFirstly
                .dropFirst(countToLeave)
                .forEach {
                    cache.remove(key: $0.key)
                }
        }
        
//        if oldCache != metadata.count {
//            print("cacheCleanup: \(oldCache) -> \(cache.count)")
//        }
    }
    
    static func automaticCacheCleanupMeta() {
        let oldCache = metadata.count
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-10) )
        
        //remove cache older than 10 sec
        metadata
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
            .filter { maxTime > $0.value.lastAccessDate }
            .forEach {
                metadata.remove(key: $0.key)
            }
        
        if oldCache != metadata.count {
            print("cacheCleanup: \(oldCache) -> \(metadata.count)")
        }
    }
    
    static func clearCache() {
        cache = [:]
    }
}

class FBCCacheItem {
    private(set) var model: UKSImagePathVM2
    private(set) var lastAccessDate: Date = Date.now
    private let path: String
    
    init(path: String) {
        self.path = path
        self.model = UKSImagePathVM2(path: path)
    }
    
    func updLastAccessDate() {
        self.lastAccessDate = Date.now
    }
}

class FBCCacheMeta {
    private(set) var model: RecentFile
    private(set) var lastAccessDate: Date = Date.now
    private let path: String
    
    init(path: String) {
        self.path = path
        self.model = RecentFile(path)
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
    var pixelSize: NSSize? {
        if let rep = self.representations.first{
            let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            return size
        }
        return nil
    }
}

class IconCache {
    private static let musicIcon = NSImage(named: "MusicIcon")
    
    static func getIcon(path: String) -> NSImage {
        if let mimeType = path.FS.info.mimeType, mimeType.conforms(to: .audio) {
            return musicIcon!
        }
        
        return path.FS.info.hiresIcon(size: Int(125))
    }
}

extension Dictionary where Key == String, Value == FBCCacheItem {
    var sizeInBytes: Int {
        class_getInstanceSize(FBCCacheItem.self) * self.count
    }
}

extension Dictionary {
    mutating func remove(key: Key) {
        guard let idx = self.index(forKey: key) else { return }
        
        self.remove(at: idx)
    }
}

