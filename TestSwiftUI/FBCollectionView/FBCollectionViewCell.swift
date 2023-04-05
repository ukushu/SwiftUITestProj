import Foundation
import AppKit
import SwiftUI

final class CollectionViewItem<ID: Hashable> : NSCollectionViewItem {
    let container = NSStackView()
    var id : ID?
    
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        self.view = container
    }
}
