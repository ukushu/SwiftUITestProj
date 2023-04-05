import Foundation
import SwiftUI
import Essentials
import AsyncNinja

struct UKSImagePath: View {
    @ObservedObject var model: UKSImagePathVM
    
    init(path: String, size: CGFloat) {
        model = UKSImagePathVM(path: path)
    }
    
    var body: some View {
        if let thumbnail = model.thumbnail {
            Image(nsImage: thumbnail)
                .resizable()
                .scaledToFit()
        } else {
            if let icon = IconCache.getIcon(path: model.path) {
                Image(nsImage: icon )
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

class UKSImagePathVM: ObservableObject {
    let path: String
    @Published var thumbnail: NSImage?
    
    private(set) var timer: TimerCall!
    
    init(path: String) {
        self.thumbnail = FBCollectionCache.getCachedImg(path: path)?.thumbnail
        self.path = path
        
        
        self.timer = TimerCall(.continious(interval: 0.1)) {
            let thumb = FBCollectionCache.getCachedImg(path: path)?.thumbnail
            
            if self.thumbnail != thumb {
                self.thumbnail = thumb
            }
        }
    }
}
