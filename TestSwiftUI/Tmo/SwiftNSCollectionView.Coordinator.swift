import SwiftUI
import Quartz

extension SwiftNSCollectionView {
    internal class Coordinator: NSObject, NSCollectionViewDelegate, NSCollectionViewDataSource { // QLPreviewPanelDelegate, QLPreviewPanelDataSource,
        var parent: SwiftNSCollectionView<ItemType, Content>
        
        var selectedItems: Binding<Set<Int>>
        
        init(_ parent: SwiftNSCollectionView<ItemType, Content>, selectedItems: Binding<Set<Int>>) {
            self.selectedItems = selectedItems
            self.parent = parent
        }
        
//        var selectedIndexPaths: Set<IndexPath> = Set<IndexPath>()
        var selectedItemsInternal: [ItemType] {
            get {
                var selectedItemsInternal: [ItemType] = []
                
                for index in selectedItems.wrappedValue {
                    selectedItemsInternal.append(parent.items[index])
                }
                
                return selectedItemsInternal
            }
        }
        
        // NSCollectionViewDelegate
        // TODO: use Set<IndexPath> version
        func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
            guard let dragHandler = parent.dragHandler else { return nil }
            
            let item = parent.items[index]
            return dragHandler(item)
        }
        
        // NSCollectionViewDataSource
        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            // Assume collectionView is the current collectionView.
            return parent.items.count
        }
        
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            // Assume collectionView is the current collectionView.
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), for: indexPath) as! CollectionViewCell<Content>
            let currentItem = parent.getItem(for: indexPath)
            
            // cell.representedObject = currentItem
            // print(cell.identifier)
            
            // print("Getting representation \(currentItem)")
            
            // cell.view = self.renderer(currentItem)
            for view in cell.container.views {
                cell.container.removeView(view)
            }
            
            let hostedView = NSHostingView<Content>(rootView:parent.renderer(currentItem))
            cell.contents = hostedView
            cell.container.addView(cell.contents!, in: .center)
            // print(cell.container.frame)
            // // hostedView.frame = cell.container.frame
            //
            // if (cell.contents == nil) {
            //     cell.contents = hostedView
            //     cell.container.addView(cell.contents!, in: .center)
            //     // cell.container.frame = NSRect(origin: cell.container.frame.origin, size: NSSize(width: 50, height: 50))
            // }
            //
            // cell.contents?.frame = cell.container.frame
            // // cell.label.isSelectable = false
            
            return cell
        }
        
        // NSCollectionViewDelegateFlowLayout
        // func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        //     print("Sizing")
        //     return NSSize(
        //         width: itemWidth ?? 400,
        //         height: itemWidth ?? 400
        //     )
        // }
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





////////////////////////////
///QucickLook
///////////////////////////

fileprivate extension SwiftNSCollectionView.Coordinator {
    var isQuickLookEnabled: Bool {
        false
        //return parent.quickLookHandler != nil
    }
}

extension SwiftNSCollectionView.Coordinator {
    func handleKeyDown(_ event: NSEvent) -> Bool {
        let spaceKeyCode: UInt16 = 49
        switch event {
        case _ where event.keyCode == spaceKeyCode:
            guard isQuickLookEnabled else {
                return false
            }
            
//                print("Space pressed & QuickLook is enabled.")
//                if let quickLook = QLPreviewPanel.shared() {
//                    let isQuickLookShowing = QLPreviewPanel.sharedPreviewPanelExists() && quickLook.isVisible
//                    if (isQuickLookShowing) {
//                        quickLook.reloadData()
//                    } else {
//                        quickLook.dataSource = self
//                        quickLook.delegate = self
//                        quickLook.center()
//                        quickLook.makeKeyAndOrderFront(nil)
//                    }
//                }
            
            return true
        default:
            return false
        }
    }
    
    // QLPreviewPanelDataSource
    func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
        guard isQuickLookEnabled else {
            return 0
        }
        
        return selectedItems.wrappedValue.count
    }
    
    // QLPreviewPanelDelegate
    // Inspired by https://stackoverflow.com/a/33923618/788168
    func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool {
        if (event.type == .keyDown) {
            print("Key down: \(event.keyCode); modifiders: \(event.modifierFlags)")
            
            // TODO: forward Option+Backspace to the NSCollectionView?
            let upArrow: UInt16 = 126
            let rightArrow: UInt16 = 124
            let downArrow: UInt16 = 125
            let leftArrow: UInt16 = 123
            switch event.keyCode {
            case upArrow: fallthrough
            case rightArrow: fallthrough
            case downArrow: fallthrough
            case leftArrow:
                if (event.modifierFlags.contains(.shift)) {
                    // Don't pass through shift-selection keys.
                    return false
                }
                // Though I believe the event is handled by QL when
                // multiple items exist, just be safe.
                if (selectedItems.wrappedValue.count <= 1) {
                    // Forward the keydown event to the NSCollectionView, which will handle moving focus.
                    parent.collectionView?.keyDown(with: event)
                    return true
                }
            default: break
                // no-op
            }
        }
        
        return false
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<Int>) {
        // Unsure if necessary to queue:
        DispatchQueue.main.async {
            self.selectedItems.wrappedValue.subtract(indexPaths)
            print("Selected items: \(self.selectedItems.wrappedValue) (removed \(indexPaths))")
            
            if let quickLook = QLPreviewPanel.shared() {
                if (quickLook.isVisible) {
                    quickLook.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: Int) {
        // Unsure if necessary to queue:
        DispatchQueue.main.async {
            // TODO: this fires too much (like when we resize the view). I think that matches actual selection behavior, but I'd like to do better.
            self.selectedItems.wrappedValue.subtract([indexPath])
            print("Selected items: \(self.selectedItems.wrappedValue) (removed \(indexPath) because item removed)")
        }
    }
    
//    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//        // Unsure if necessary to queue:
//        DispatchQueue.main.async {
//            self.selectedIndexPaths.formUnion(indexPaths)
//            print("Selected items: \(self.selectedIndexPaths) (added \(indexPaths))")
//
//            if let quickLook = QLPreviewPanel.shared() {
//                if (quickLook.isVisible) {
//                    quickLook.reloadData()
//                }
//            }
//        }
//    }
    
//        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
//            guard isQuickLookEnabled else {
//                return nil
//            }
//
//            guard let quickLookHandler = parent.quickLookHandler, let urls = quickLookHandler(selectedItemsInternal) else {
//                // If no URLs, return.
//                return nil
//            }
//
//            return urls[index] as QLPreviewItem?
//        }
}
