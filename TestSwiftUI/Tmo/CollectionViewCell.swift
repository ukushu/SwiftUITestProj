//
//  CollectionViewCell.swift
//  TestSwiftUI
//
//  Created by UKS on 02.03.2023.
//

import Foundation
import AppKit
import SwiftUI

final class CollectionViewCell<Content: View>: NSCollectionViewItem {
    var selectedCGColor: CGColor { NSColor.selectedControlColor.cgColor }
    var nonSelectedCGColor: CGColor { NSColor.clear.cgColor }
    
    // TODO: also highlight/hover state!
    // TODO: pass to Content
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderColor = selectedCGColor
                view.layer?.borderWidth = 3
            } else {
                view.layer?.borderColor = nonSelectedCGColor
                view.layer?.borderWidth = 0
            }
        }
    }
    
    var contents: NSView?
    let container = NSStackView()
    
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        
        self.view = container
    }
}
