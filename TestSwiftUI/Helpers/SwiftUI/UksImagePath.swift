///////////////////////////
// OPTIMIZED
//////////////////////////





import Foundation
import SwiftUI
import Essentials
import AsyncNinja

struct UKSImagePath: View {
    let path: String
    let size: CGFloat
    
    @State private var thumbnail: NSImage? = nil //{ didSet{ print("path ZZ: \(path)") } }
    
    var body: some View {
        if let thumbnail = thumbnail {
            Image(nsImage: thumbnail)
                .resizable()
                .scaledToFit()
        } else {
            if let icon = IconCache.getIcon(path:path) {
                Image(nsImage: icon )
                    .resizable()
                    .scaledToFit()
                    .onAppear(perform: generateThumbnail) // << here !!
            }
        }
    }
    
    func generateThumbnail() {
        updThumbnailFromHdd()
    }
    
    func updThumbnailFromHdd() {
        DispatchQueue.global(qos: .background).async {
            self.thumbnail = imgThumbnailAdv(size, path: path)
        }
    }
}



//struct UKSImage2: View {
//    let url: URL
//    let size: CGFloat
//
//    @State private var thumbnail: NSImage? = nil
//
//    var body: some View {
//        if let thumbnail = thumbnail {
//            Image(nsImage: thumbnail)
//                .resizable()
//                .scaledToFit()
//        } else {
//            Space(size)
//              .onAppear(perform: generateThumbnail) // << here !!
//        }
//    }
//
//    func generateThumbnail() {
//        DispatchQueue.global(qos: .background).async {
//            self.thumbnail = url.imgThumbnailAdv(size)
//        }
//    }
//}


fileprivate extension URL {
    func imgThumbnailAdv(_ size: CGFloat) -> NSImage? {
        TestSwiftUI.imgThumbnailAdv(size, path: self.path)
    }
}


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
    var pixelSize: NSSize?{
        if let rep = self.representations.first{
            let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            return size
        }
        return nil
    }
}


class IconCache {
    private static let musicIcon = NSImage(named: "MusicIcon")
    
    static func getIcon(path: String) -> NSImage? {
        if let mimeType = path.FS.info.mimeType, mimeType.conforms(to: .audio) {
            return musicIcon
        }
        
        return NSWorkspace.shared.icon(forFile: path)
    }
}
