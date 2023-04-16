import Foundation
import SwiftUI
import QuickLookThumbnailing

struct UKSImagePath2: View {
    @ObservedObject var model: UKSImagePathVM2
    
    init(path: String, size: CGFloat) {
        model = FBCollectionCache.getFor(path: path).model
    }
    
    var body: some View {
        TrueBody()
            .onAppear{
                model.requestThumbnail()
            }
    }
    
    @ViewBuilder
    func TrueBody() -> some View {
        if let thumbnail = model.thumbnail {
            Image(nsImage: thumbnail)
                .resizable()
                .scaledToFit()
        } else if let icon = model.icon {
            Image(nsImage: icon )
                .resizable()
                .scaledToFit()
        }
    }
}

class UKSImagePathVM2: ObservableObject {
    private let path: String
    @Published var icon: NSImage? = nil
    @Published var thumbnail: NSImage?
    private var request: QLThumbnailGenerator.Request?
    
    init(path: String) {
        self.path = path
        
        if path.ends(with: ".DS_Store") {
            self.icon = IconCache.getIcon(path: path)
        }
        
        if path.FS.info.isDirectory || path.lowercased().hasSuffix(extensionsExceptions) {
            request = nil
            
            path.FS.info.hiresQLThumbnail(size: 125)
                .onSuccess { img in
                    DispatchQueue.main.async {
                        self.thumbnail = img
                    }
                }
                .onFailure { _ in
                    DispatchQueue.main.async {
                        self.icon = IconCache.getIcon(path:path)
                    }
                }
        } else {
            request = QLThumbnailGenerator.Request(fileAt: path.asURL(), size: CGSize(width: 125, height: 125), scale: 1.0, representationTypes: .thumbnail)
        }
    }
    
    func requestThumbnail() {
        guard self.thumbnail == nil else { return }
        guard let request = self.request else { return }
        
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        { [weak self] (thumbnail, error) in
            guard let me = self else { return }
            
            DispatchQueue.main.async {
                if let thumbnail = thumbnail {
                    me.thumbnail = thumbnail.nsImage
                    me.request = nil
                } else {
                    // Handle the error case gracefully.
                }
            }
        }
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
