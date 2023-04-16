import SwiftUI
import QuickLookThumbnailing
import Essentials

public class FBCollectionCache {
    static let thumbnailSize: Int = 125
    
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
        let countToLeave = 300
        let countToDoCleanup = Int( 1.2 * Double(countToLeave) )
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-20))
        let fullCleanTime = Date.now.addingTimeInterval(TimeInterval(-40))
        
        //clean older than maxTimeSec
        let cashSortedNewFirstly = cache
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
        
        cashSortedNewFirstly
            .filter { fullCleanTime > $0.value.lastAccessDate }
            .forEach {
                cache.remove(key: $0.key)
            }
        
        cashSortedNewFirstly
            .dropFirst(minCountToLeave)
            // clean older than maxTime. Correctly works
            .filter { maxTime > $0.value.lastAccessDate }
            .forEach {
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
//        let oldCache = metadata.count
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-10) )
        
        //remove cache older than 10 sec
        metadata
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
            .filter { maxTime > $0.value.lastAccessDate }
            .forEach {
                metadata.remove(key: $0.key)
            }
        
//        if oldCache != metadata.count {
//            print("cacheCleanup: \(oldCache) -> \(metadata.count)")
//        }
    }
    
    static func clearCache() {
        if !cache.isEmpty {
            cache = [:]
        }
        
        if !metadata.isEmpty {
            metadata = [:]
        }
    }
}

class FBCCacheItem {
    private(set) var model: FilePreviewVM
    private(set) var lastAccessDate: Date = Date.now
    private let path: String
    
    init(path: String) {
        self.path = path
        self.model = FilePreviewVM(path: path)
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

extension NSImage {
    var pixelSize: NSSize? {
        guard let rep = self.representations.first else { return nil }
        
        return NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
    }
}

class IconCache {
    private static let musicIcon = NSImage(named: "MusicIcon")
    private static var dsStore: NSImage?
    
    static func getIcon(path: String) -> NSImage {
        if path.ends(with: ".DS_Store") {
            if let dsStore = dsStore {
                return dsStore
            } else {
                let img = path.FS.info.hiresIcon(size: Int(FBCollectionCache.thumbnailSize))
                dsStore = img
                return img
            }
        }
        
        if let mimeType = path.FS.info.mimeType, mimeType.conforms(to: .audio) {
            return musicIcon!
        }
        
        return path.FS.info.hiresIcon(size: Int(FBCollectionCache.thumbnailSize))
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
