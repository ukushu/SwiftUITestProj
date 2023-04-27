import Foundation
import AppKit
import SwiftUI

final class CollectionViewItem : NSCollectionViewItem {
    let container = NSStackView()
    
    var acceptsMouseDown: Bool = true
}

extension CollectionViewItem {
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
    }
}
