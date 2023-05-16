import SwiftUI
import QuickLookThumbnailing
import Essentials

// REWRITE TO SINGLETONE!
public class FBCollectionCache {
    static let thumbnailSize: Int = 125
    
    private static var cache: [URL : FBCCacheItem] = [:]
    private static var metadata: [URL : FBCCacheMeta] = [:]
    
    private static let timer = TimerCall(.continious(interval: 1)) {
        automaticCacheCleanup()
//        automaticCacheCleanupMeta()
    }
    
    static func getFor(url: URL) -> FBCCacheItem {
        let _ = FBCollectionCache.timer
        
        if let item = cache[url] {
            let itemNew = FBCCacheItem(from: item)
            cache[url] = itemNew
            return itemNew
        }
        
        let newItem = FBCCacheItem(url: url)
        cache[url] = newItem
        
        return newItem
    }
    
    static func getMetaFor(url: URL) -> RecentFile {
//        AppCore.log(title: "1", msg: "getMetaFor", thread: true)
        
        if let item = metadata[url] {
            return item.model
        }
        
        let newItem = FBCCacheMeta(url: url)
        metadata[url] = newItem
        
        return newItem.model
    }
    
    static func setMetaFor(mdItems: [MDItem]) {
        metadata = mdItems.map{ FBCCacheMeta(mdItem: $0) }
            .toDictionary(key: \.model.url, block: { $0 } )
    }
    
    static func setMetaFor(urls: [URL]) {
        metadata = urls.chunked(by: 100).map{ $0.map{ FBCCacheMeta(url: $0) } }
            .flatMap{ $0 }
            .toDictionary(key: \.model.url, block: { $0 } )
    }
    
    static func automaticCacheCleanup() {
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
    
    init(from item: FBCCacheItem) {
        self.url = item.url
        self.model = item.model
    }
}

struct FBCCacheMeta {
    private(set) var model: RecentFile
    private(set) var lastAccessDate: Date = Date.now
    private let url: URL
    
    init(url: URL) {
        self.url = url
        self.model = RecentFile(url)
    }
    
    init(mdItem: MDItem) {
        self.url = mdItem.path!.asURL()
        self.model = RecentFile(url)
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
