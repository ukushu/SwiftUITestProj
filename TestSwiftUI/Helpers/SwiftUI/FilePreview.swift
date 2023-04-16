import Foundation
import SwiftUI
import QuickLookThumbnailing
import AsyncNinja

struct FilePreview: View {
    @ObservedObject var model: FilePreviewVM
    
    init(url: URL) {
        model = FBCollectionCache.getFor(url: url).model
    }
    
    var body: some View {
        TrueBody()
    }
    
    @ViewBuilder
    func TrueBody() -> some View {
        if let thumbnail = model.thumbnail {
            Image(nsImage: thumbnail)
        }
    }
}

class FilePreviewVM: NinjaContext.Main, ObservableObject {
    private let url: URL
    @Published var thumbnail: NSImage?
    
    init(url: URL) {
        self.url = url
        super.init()
        
        requestThumbnail()
    }
    
    func requestThumbnail() {
        if url.path.ends(with: ".DS_Store") {
            self.thumbnail = IconCache.getIcon(path: url.path)
            return
        }
        
        url.path.FS.info.hiresQLThumbnail(size: 125)
            .onSuccess(executor: .main) { img in
                self.thumbnail = img
            }
            .onFailure(executor: .main) { _ in
                self.thumbnail = IconCache.getIcon(path: self.url.path)
            }
        
        if extensionsExceptions.contains(url.pathExtension) {
            thumbnailReload()
        }
    }
    
    //This is hack to get more accurate preview of some sort of files
    func thumbnailReload() {
        future(value: .success(()))
            .delayed(timeout: 0.15)
            .flatMap(context: self) { me, _ in me.url.path.FS.info.hiresQLThumbnail(size: 125) }
            .onSuccess(executor: .main) { img in
                self.thumbnail = img
            }
    }
}

extension FilePreviewVM {
    func assignIcon(thumbnail: QLThumbnailRepresentation?) {
        self.thumbnail = thumbnail?.nsImage ?? IconCache.getIcon(path: self.url.path)
    }
}


fileprivate let extensionsExceptions: [String]  = ["txt","docx","doc","pages","odt","rtf","tex","wpd","ltxd",
                                                   "btxt","dotx","wtt","dsc","me","ans","log","xy","text","docm",
                                                   "wps","rst","readme","asc","strings","docz","docxml","sdoc",
                                                   "plain","notes","latex","utxt","ascii",

                                                   "xlsx","patch","xls","xlsm","ods",

                                                   "py","cs","swift","html","css", "fountain","gscript","lua",

                                                   "markdown","md",
                                                   "plist", "ips",

                                                   "ass","str"
            ]

public class NinjaContext {
    open class Main : ExecutionContext, ReleasePoolOwner {
        public var executor    = Executor.init(queue: DispatchQueue.main)
        public let releasePool = ReleasePool()
        
        public init() {}
    }
    
    open class Global : ExecutionContext, ReleasePoolOwner {
        public var executor    = Executor.init(queue: DispatchQueue.global(qos: .userInteractive))
        public let releasePool = ReleasePool()
        
        public init() {}
    }
}
