import Foundation
import SwiftUI
import QuickLookThumbnailing

struct UKSImagePath2: View {
    @ObservedObject var model: UKSImagePathVM2
    
    init(path: String, size: CGFloat) {
        model = UKSImagePathVM2(path: path)
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
    let path: String
    @Published var icon: NSImage? = nil
    @Published var thumbnail: NSImage?
    private let request: QLThumbnailGenerator.Request?
    
    init(path: String) {
        self.path = path
        
        self.icon = IconCache.getIcon(path:path)
        self.thumbnail = FBCollectionCache.getFor(path: path)?.thumbnail
        self.icon = path.FS.info.hiresIcon(size: Int(125))
        
        if path.FS.info.isDirectory || path.lowercased().hasSuffix(extensionsExceptions) {
            request = nil
            
            path.FS.info.hiresQLThumbnail(size: 125)
                .onSuccess { [weak self] in
                    self?.icon = $0
                }
        } else {
            request = QLThumbnailGenerator.Request(fileAt: path.asURL(), size: CGSize(width: 125, height: 125), scale: 1.0, representationTypes: .thumbnail)
        }
    }
    
    func requestThumbnail() {
        guard self.thumbnail == nil else { return }
        guard let request = self.request else { return }
        
        QLThumbnailGenerator.shared.generateRepresentations(for: request)
        { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if let thumbnail = thumbnail {
                    self.thumbnail = thumbnail.nsImage
                    FBCollectionCache.setFor(path: self.path, image: thumbnail.nsImage)
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
                                                   "plist", "ips"
            ]
