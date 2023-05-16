import Foundation
import SwiftUI

final class FBCItemView : NSCollectionViewItem {
    let container = NSStackView()
    
    var acceptsMouseDown: Bool = true
    
    var url: URL?
    var index: Int?
}

extension FBCItemView {
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        self.view = container
    }
    
    override func mouseDown(with event: NSEvent) {
        if acceptsMouseDown {
            super.mouseDown(with: event)
        } else {
            
        }
        
        if event.clickCount == 2 {
//            self.url?.FS.openWithAssociatedApp()
        }
    }
}
