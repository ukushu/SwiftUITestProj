import Foundation

class RecentFile: Identifiable {
    var id: String { self.path }
    let path: String
    lazy var url: URL = self.path.asURL()
    
    private var urlComponentsCache: [URL] = []
    var urlComponents: [URL] {
        if urlComponentsCache.count == 0 {
            self.urlComponentsCache = self.path.asURL().urlComponentsUrls()
            return urlComponentsCache
        }
        
        return urlComponentsCache
    }
    
    var urlComponentsDirsOnly: [URL] {
        if let last = urlComponents.last {
            return last.isDirectory ? urlComponents : urlComponents.dropLast()
        }
        
        return []
    }
    
    var name: String { path.FS.info.nameWithoutAppExt }
    
    let mdItem: MDItem
    let metadata: [String : Any]
    
    private var displayDateDir: Date? {
        path.FS.info.creationDate ?? path.FS.info.lastUseDate ??  path.FS.info.modificationDate
    }
    
//    var displayDate: Date? {
//        if path.FS.info.isDirectory {
//            return displayDateDir
//        }
//
//        return path.FS.info.lastAccessDate ?? mdItem.dateLastUse ?? path.FS.info.modificationDate ?? mdItem.dateLastAttrChange
//    }
    
//    var useDate: Date? {
//        lastUseDate
////        if path.FS.info.isDirectory {
////            return displayDateDir
////        }
////
////        return path.FS.info.lastAccessDate ?? path.FS.info.modificationDate ?? mdItem.dateLastAttrChange// ??  path.FS.info.modificationDate ?? path.FS.info.creationDate
//    }
    
    var lastUseDate: Date? {
        if self.path.FS.info.isDirectory {
            if let dateAdded = self.metadata.kMDItemDateAdded {
                return dateAdded
            }
            
            return self.metadata.kMDItemAttributeChangeDate ?? self.metadata.kMDItemFSCreationDate ?? addedToCacheDate
        }
        
//        if let lastUse = path.FS.info.lastUseDate { //mdItem.dateLastUse {
//            return lastUse
//        }
        
        if let contentMod = self.metadata.kMDItemContentModificationDate,
           let dateAdded = self.metadata.kMDItemDateAdded
        {
            return max(contentMod, dateAdded)
        } else if let contentMod = self.metadata.kMDItemContentModificationDate {
            return contentMod
        } else if let dateAdded = self.metadata.kMDItemDateAdded {
            return dateAdded
        }
        
        return self.metadata.kMDItemAttributeChangeDate ?? self.metadata.kMDItemFSCreationDate ?? addedToCacheDate
    }
    
    private let addedToCacheDate: Date
    
    let isDirectory: Bool
    
    init?(_ mdItem: MDItem) {
        guard let path = mdItem.path else { return nil }
        
        self.path = path
        
        self.isDirectory = path.FS.info.isDirectory
        
        self.mdItem = mdItem
        
        self.metadata = path.FS.info.getAttributes()
        self.addedToCacheDate = Date()
    }
}

public extension String {
    func asURLdir() -> URL {
        URL(fileURLWithPath: self, isDirectory: true )
    }
    
    func asURL(isDirectory: Bool? = nil) -> URL {
        return isDirectory == nil ? URL(fileURLWithPath: self) : URL(fileURLWithPath: self, isDirectory: isDirectory! )
    }
    
    func asBrowserUrl() -> URL? {
        return URL(string: self)
    }
}


fileprivate extension URL {
    func urlComponentsUrls() -> [URL] {
        var urls:[URL] = []
        
        //let needToDropBeginning = self.path.starts(with: "/Users/\(NSUserName())")
        
        var tmpUrl = self
        
        urls.append(self)
        
        if tmpUrl.path.starts(with: "/Users/\(NSUserName())") {
            while tmpUrl.pathComponents.count > 4 {
                tmpUrl = tmpUrl.deletingLastPathComponent()
                urls.append(tmpUrl)
            }
        } else {
            while tmpUrl.pathComponents.count >= 3  {
                tmpUrl = tmpUrl.deletingLastPathComponent()
                urls.append(tmpUrl)
            }
        }
        
        return urls.reversed()
    }
}

fileprivate extension Dictionary where Key == String, Value == Any {
    var kMDItemDateAdded: Date? {
        self["kMDItemDateAdded"] as? Date
    }
    
    var kMDItemAttributeChangeDate: Date? {
        self["kMDItemAttributeChangeDate"] as? Date
    }
    
    var kMDItemContentModificationDate: Date? {
        self["kMDItemContentModificationDate"] as? Date
    }
    
    var kMDItemFSCreationDate: Date? {
        self["kMDItemFSCreationDate"] as? Date
    }
}


private extension FSFileInfo {
    var nameWithoutAppExt: String {
        self.name.ends(with: ".app") ? self.name.dropLast(4).asString() : self.name
    }
}

public extension String {
    func ends(with suffix: String) -> Bool {
        self.hasSuffix(suffix)
    }
    
    func ends(with suffixes: [String]) -> Bool {
        self.hasSuffix(suffixes)
    }
    
    func starts(with prefix: String) -> Bool {
        self.hasPrefix(prefix)
    }
    
    func starts(with prefixes: [String]) -> Bool {
        self.hasPrefix(prefixes)
    }
}


public extension String {
    func hasSuffix(_ suffixes:[String]) -> Bool {
        for s in suffixes {
            if self.hasSuffix(s) {
                return true
            }
        }
        
        return false
    }
    
    func hasPrefix(_ prefixes:[String]) -> Bool {
        for s in prefixes {
            if self.hasPrefix(s) {
                return true
            }
        }
        
        return false
    }
}
