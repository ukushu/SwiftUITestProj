import Foundation
import SwiftUI
import QuickLook
import QuickLookThumbnailing

public class FBCollectionCache {
    
    
    
    
}

class FBCCacheItem {
    private(set) var icon: NSImage? = nil
    private(set) var thumbnail: NSImage? = nil
    let date: Date
    
    init(path: String) {
        self.date = Date.now
        
        DispatchQueue.global(qos: .background).async {
            self.thumbnail = imgThumbnailAdv(125, path: path)
        }
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
