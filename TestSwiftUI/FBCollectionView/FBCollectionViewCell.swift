import Foundation
import AppKit
import SwiftUI

final class CollectionViewItem : NSCollectionViewItem {
    let container = NSStackView()
    
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        self.view = container
    }
}
