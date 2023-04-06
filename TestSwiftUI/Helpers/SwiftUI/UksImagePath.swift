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
        TrueBody()
            .onAppear{ model.tryLoadIfNeeded() }
    }
    
    @ViewBuilder
    func TrueBody() -> some View {
        if let thumbnail = model.thumbnail {
            Image(nsImage: thumbnail)
                .resizable()
                .scaledToFit()
        } else if let icon = IconCache.getIcon(path: model.path) {
            Image(nsImage: icon )
                .resizable()
                .scaledToFit()
        }
    }
}

class UKSImagePathVM: ObservableObject {
    let path: String
    @Published var thumbnail: NSImage?
    
    private(set) var timer: TimerCall!
    
    var readyToLoad = false
    
    init(path: String) {
        self.thumbnail = FBCollectionCache.getCachedImg(path: path)?.thumbnail
        self.path = path
        
        self.timer = TimerCall(.continious(interval: 0.09)) {
            if self.readyToLoad {
                let thumb = FBCollectionCache.getCachedImg(path: path)?.thumbnail
                
                //update only in case not the same
                self.thumbnail = thumb
                self.readyToLoad = false
            }
        }
    }
    
    func tryLoadIfNeeded() {
        if thumbnail == nil {
            readyToLoad = true;
        }
    }
}
