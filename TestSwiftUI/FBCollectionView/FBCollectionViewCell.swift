import Foundation
import AppKit
import SwiftUI

final class CollectionViewItem : NSCollectionViewItem {
    let container = NSStackView()
    
    var selectedCGColor: CGColor    { Color(rgbaHex: 0x00900050).cgColor! }
    var nonSelectedCGColor: CGColor { NSColor.clear.cgColor }
    
    // TODO: also highlight/hover state!
    // TODO: pass to Content
    override var isSelected: Bool
    {
        didSet {
            if isSelected {
                view.layer?.backgroundColor = selectedCGColor
                view.layer?.masksToBounds = true
                //view.layer?.cornerRadius = 5.0
                
                //view.layer?.contents = Space().background(Color.red)//.frame(width: 100, height: 10)
            } else {
                view.layer?.backgroundColor = nonSelectedCGColor
                view.layer?.masksToBounds = false
            }
        }
    }
    
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        self.view = container
    }
}

//final class FBCollectionViewCell<Content: View>: NSCollectionViewItem {
//    var selectedCGColor: CGColor    { Color(rgbaHex: 0x00900050).cgColor! }
//    var nonSelectedCGColor: CGColor { NSColor.clear.cgColor }
//
//    // TODO: also highlight/hover state!
//    // TODO: pass to Content
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                view.layer?.backgroundColor = selectedCGColor
//                view.layer?.masksToBounds = true
//                view.layer?.cornerRadius = 5.0
//            } else {
//                view.layer?.backgroundColor = nonSelectedCGColor
//                view.layer?.masksToBounds = false
//            }
//        }
//    }
//
//    var contents: NSView?
//    let container = NSStackView()
//
//    override func loadView() {
//        container.orientation = NSUserInterfaceLayoutOrientation.vertical
//        container.wantsLayer = true
//
//        self.view = container
//    }
//}
