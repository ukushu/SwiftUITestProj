import Foundation

class RecentFile {
//    var id: String { self.url.path }
    var url: URL
    
    lazy var urlComponents: [URL] = url.urlComponentsUrls()
    
    lazy var urlComponentsDirsOnly: [URL] = urlComponents.last == nil ? [] : urlComponents.last!.isDirectory ? urlComponents : urlComponents.dropLast()
    
    lazy var name: String = url.path.FS.info.nameWithoutAppExt
    
    static let attrToGrab = ["kMDItemDateAdded","kMDItemAttributeChangeDate","kMDItemContentModificationDate", "kMDItemFSCreationDate"]
    lazy var metadata: [String : Any]? = url.path.FS.info.getAttributes(forAttributes: RecentFile.attrToGrab)
    
    func refreshMetadata() {
        metadata = url.path.FS.info.getAttributes(forAttributes: RecentFile.attrToGrab)
    }
    
    private var displayDateDir: Date? {
        url.path.FS.info.creationDate ?? url.path.FS.info.lastUseDate ?? url.path.FS.info.modificationDate
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
        if self.url.path.FS.info.isDirectory {
            if let dateAdded = self.metadata?.kMDItemDateAdded {
                return dateAdded
            }
            
            return self.metadata?.kMDItemAttributeChangeDate ?? self.metadata?.kMDItemFSCreationDate ?? addedToCacheDate
        }
        
//        if let lastUse = path.FS.info.lastUseDate { //mdItem.dateLastUse {
//            return lastUse
//        }
        
        if let contentMod = self.metadata?.kMDItemContentModificationDate,
           let dateAdded = self.metadata?.kMDItemDateAdded
        {
            return max(contentMod, dateAdded)
        } else if let contentMod = self.metadata?.kMDItemContentModificationDate {
            return contentMod
        } else if let dateAdded = self.metadata?.kMDItemDateAdded {
            return dateAdded
        }
        
        return self.metadata?.kMDItemAttributeChangeDate ?? self.metadata?.kMDItemFSCreationDate ?? addedToCacheDate
    }
    
    private let addedToCacheDate: Date = Date.now
    
    lazy var isDirectory: Bool = self.url.FS.info.isDirectory
    
    init(_ url: URL) {
        self.url = url
    }
}

extension RecentFile: Hashable {
    static func == (lhs: RecentFile, rhs: RecentFile) -> Bool {
        lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.url.path)
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
