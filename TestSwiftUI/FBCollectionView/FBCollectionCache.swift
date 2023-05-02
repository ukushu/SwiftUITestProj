import SwiftUI
import QuickLookThumbnailing
import Essentials

public class FBCollectionCache {
    static let thumbnailSize: Int = 125
    
    private static var cache: [URL : FBCCacheItem] = [:]
    private static var metadata: [URL : FBCCacheMeta] = [:]
    
    private static let timer = TimerCall(.continious(interval: 1)) {
        automaticCacheCleanup()
        automaticCacheCleanupMeta()
    }
    
    static func getFor(url: URL) -> FBCCacheItem {
        let _ = FBCollectionCache.timer
        
        if let item = cache[url] {
            item.updLastAccessDate()
            return item
        }
        
        let newItem = FBCCacheItem(url: url)
        cache[url] = newItem
        
        return newItem
    }
    
    static func getMetaFor(url: URL) -> RecentFile {
        if let item = metadata[url] {
            return item.model
        }
        
        let newItem = FBCCacheMeta(url: url)
        metadata[url] = newItem
        
        return newItem.model
    }
    
    static func automaticCacheCleanup() {
//        let oldCache = cache.count
        
        let minCountToLeave = 18
        let countToLeave = 300
        let countToDoCleanup = Int( 1.2 * Double(countToLeave) )
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-20))
        
        //clean older than maxTimeSec
        let cashSortedNewFirstly = cache
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
        
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
        let oldCache = metadata.count
        let maxTime = Date.now.addingTimeInterval(TimeInterval(-30) )
        
//        remove cache older than N sec
        metadata
            .sorted { $0.value.lastAccessDate > $1.value.lastAccessDate }
            .filter { maxTime > $0.value.lastAccessDate }
            .forEach {
                metadata.remove(key: $0.key)
            }
        
        if oldCache != metadata.count {
            print("cacheCleanup: \(oldCache) -> \(metadata.count)")
        }
//        print("dict weight: \(metadata.sizeInBytes)")
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
    private let url: URL
    
    init(url: URL) {
        self.url = url
        self.model = FilePreviewVM(url: url)
    }
    
    func updLastAccessDate() {
        self.lastAccessDate = Date.now
    }
}

class FBCCacheMeta {
    private(set) var model: RecentFile
    private(set) var lastAccessDate: Date = Date.now
    private let url: URL
    
    init(url: URL) {
        self.url = url
        self.model = RecentFile(url)
    }
    
    func updLastAccessDate() {
        self.lastAccessDate = Date.now
    }
}

//////////////////////////////////
///HELPERS
/////////////////////////////////

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
