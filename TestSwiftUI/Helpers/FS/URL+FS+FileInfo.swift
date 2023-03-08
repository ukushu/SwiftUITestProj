import Foundation

public class FSUrlFileInfo {
    private let obj: FSurl
    public var url: URL { obj.url }
    
    public init(obj: FSurl) {
        self.obj = obj
    }
}

public extension FSUrlFileInfo {
    var isDirectory: Bool {
        return (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
