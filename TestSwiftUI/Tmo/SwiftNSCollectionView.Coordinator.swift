import SwiftUI
//import Quartz

extension SwiftNSCollectionView {
    internal class Coordinator: NSObject, NSCollectionViewDelegate, NSCollectionViewDataSource { // QLPreviewPanelDelegate, QLPreviewPanelDataSource,
        var parent: SwiftNSCollectionView<ItemType, Content>
        
        var items: [ItemType]
        
        var selections: Binding<Set<Int>>
        
        init(_ parent: SwiftNSCollectionView<ItemType, Content>, items: [ItemType], selections: Binding<Set<Int>>) {
            self.items = items
            self.selections = selections
            self.parent = parent
        }
        
        //CORRECT!
        // NSCollectionViewDataSource
        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            return items.count
        }
        
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            let currentItem = parent.getItem(for: indexPath)
            
            // Assume collectionView is the current collectionView.
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), for: indexPath) as! CollectionViewCell<Content>
            cell.representedObject = currentItem
            cell.container.removeViewsAll()
            cell.contents = NSHostingView(rootView: parent.renderer(currentItem) )
            cell.container.addView(cell.contents!, in: .center)
            
            return cell
        }
    }
}

/////////////////////////
/// HELPERS
////////////////////////
fileprivate extension SwiftNSCollectionView {
    func getItem(for indexPath: IndexPath) -> ItemType {
        return items[indexPath.item]
    }
}

fileprivate extension NSStackView {
    func removeViewsAll() {
        for view in self.views {
            self.removeView(view)
        }
    }
}




////////////////////////////
///QucickLook
///////////////////////////
//
//fileprivate extension SwiftNSCollectionView.Coordinator {
//    var isQuickLookEnabled: Bool {
//        false
//        //return parent.quickLookHandler != nil
//    }
//}

//extension SwiftNSCollectionView.Coordinator {
//    func handleKeyDown(_ event: NSEvent) -> Bool {
//        let spaceKeyCode: UInt16 = 49
//        switch event {
//        case _ where event.keyCode == spaceKeyCode:
//            guard isQuickLookEnabled else {
//                return false
//            }
//            
////                print("Space pressed & QuickLook is enabled.")
////                if let quickLook = QLPreviewPanel.shared() {
////                    let isQuickLookShowing = QLPreviewPanel.sharedPreviewPanelExists() && quickLook.isVisible
////                    if (isQuickLookShowing) {
////                        quickLook.reloadData()
////                    } else {
////                        quickLook.dataSource = self
////                        quickLook.delegate = self
////                        quickLook.center()
////                        quickLook.makeKeyAndOrderFront(nil)
////                    }
////                }
//            
//            return true
//        default:
//            return false
//        }
//    }
//    
//    // QLPreviewPanelDataSource
//    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
//        guard isQuickLookEnabled else {
//            return 0
//        }
//        
//        return selectedItems.wrappedValue.count
//    }
//    
//    // QLPreviewPanelDelegate
//    // Inspired by https://stackoverflow.com/a/33923618/788168
//    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
//        if (event.type == .keyDown) {
//            print("Key down: \(event.keyCode); modifiders: \(event.modifierFlags)")
//            
//            // TODO: forward Option+Backspace to the NSCollectionView?
//            let upArrow: UInt16 = 126
//            let rightArrow: UInt16 = 124
//            let downArrow: UInt16 = 125
//            let leftArrow: UInt16 = 123
//            switch event.keyCode {
//            case upArrow: fallthrough
//            case rightArrow: fallthrough
//            case downArrow: fallthrough
//            case leftArrow:
//                if (event.modifierFlags.contains(.shift)) {
//                    // Don't pass through shift-selection keys.
//                    return false
//                }
//                // Though I believe the event is handled by QL when
//                // multiple items exist, just be safe.
//                if (selectedItems.wrappedValue.count <= 1) {
//                    // Forward the keydown event to the NSCollectionView, which will handle moving focus.
//                    parent.collectionView?.keyDown(with: event)
//                    return true
//                }
//            default: break
//                // no-op
//            }
//        }
//        
//        return false
//    }
//    
//    
//    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<Int>) {
//        // Unsure if necessary to queue:
//        DispatchQueue.main.async {
//            self.selectedItems.wrappedValue.subtract(indexPaths)
//            print("Selected items: \(self.selectedItems.wrappedValue) (removed \(indexPaths))")
//            
//            if let quickLook = QLPreviewPanel.shared() {
//                if (quickLook.isVisible) {
//                    quickLook.reloadData()
//                }
//            }
//        }
//    }
//    
//    func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: Int) {
//        // Unsure if necessary to queue:
//        DispatchQueue.main.async {
//            // TODO: this fires too much (like when we resize the view). I think that matches actual selection behavior, but I'd like to do better.
//            self.selectedItems.wrappedValue.subtract([indexPath])
//            print("Selected items: \(self.selectedItems.wrappedValue) (removed \(indexPath) because item removed)")
//        }
//    }
//    
////    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
////        // Unsure if necessary to queue:
////        DispatchQueue.main.async {
////            self.selectedIndexPaths.formUnion(indexPaths)
////            print("Selected items: \(self.selectedIndexPaths) (added \(indexPaths))")
////
////            if let quickLook = QLPreviewPanel.shared() {
////                if (quickLook.isVisible) {
////                    quickLook.reloadData()
////                }
////            }
////        }
////    }
//    
////        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
////            guard isQuickLookEnabled else {
////                return nil
////            }
////
////            guard let quickLookHandler = parent.quickLookHandler, let urls = quickLookHandler(selectedItemsInternal) else {
////                // If no URLs, return.
////                return nil
////            }
////
////            return urls[index] as QLPreviewItem?
////        }
//}
