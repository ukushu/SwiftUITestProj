import SwiftUI
import Combine
import Quartz

extension FBCollectionView {
    class CoordinatorAndDataSource: NSObject, NSCollectionViewDelegate,
                                    NSCollectionViewDataSource,
                                    QLPreviewPanelDelegate, QLPreviewPanelDataSource  {
        var parent: FBCollectionView<ItemType, Content>
        
        @Binding var items: [ItemType]
        
        @Binding var selections: Set<Int>
        
        private var cancellable: AnyCancellable?
        private var cancellable2: AnyCancellable?
        
        var quickLookHandler: ( () -> [URL]? )!
        
        private var scrollToTopCancellable: AnyCancellable?
        
        init(_ parent: FBCollectionView<ItemType, Content>) {
            self.parent = parent
            self._items = parent.$items
            self._selections = parent.$selectedItems
            
            super.init()
            
            self.quickLookHandler = { self.items as? [URL] ?? (self.items as? [RecentFile] )?.map{ $0.url } }
            
            self.cancellable = items.publisher.sink { [weak self] _ in
                print("items changed; reloading")
                self?.reloadData()
            }
            
            self.cancellable2 = selections.publisher.sink { [weak self] _ in
                print("selections changed; reloading")
                self?.reloadData()
            }
            
            //WORKS!
            self.scrollToTopCancellable = parent.scrollToTop?.sink { [weak self] _ in
//                print("scrolling to top")
                DispatchQueue.main.async {
                    self?.parent.scrollView.documentView?.scroll(.zero)
                }
            }
        }
        
        func reloadData() {
            self._items = parent.$items
            self._selections = parent.$selectedItems
            
            // this method already in DispatchQueue.main
            self.parent.reload()
//            self.parent.updateNSView(<#T##NSScrollView#>, context: <#T##Context#>)
        }
        
        //////////////////////////////////////////////////////
        // Data Source implementation
        //////////////////////////////////////////////////////
        
        //CORRECT!
        func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
            return items.count
        }
             
        //NSCollectionViewDataSource
        func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
            let currentItem = items[indexPath.item]
            
            let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Cell"), for: indexPath) as! FBCollectionViewCell<Content>
            
//            cell.prepareForReuse()
            
            cell.container.replaceViewFor(currentItem, usingRenderer: parent.renderer)
            cell.contents = cell.container.views.first
            cell.representedObject = currentItem
            
            return cell
        }
        
        ////////////////////////
        ///SELECTION + QuickLook
        ////////////////////////
        
//        func collectionView(_ collectionView: NSCollectionView, didEndDisplaying item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
//            // Unsure if necessary to queue:
//            DispatchQueue.main.async {
//                // TODO: this fires too much (like when we resize the view). I think that matches actual selection behavior, but I'd like to do better.
//                self.$selections.wrappedValue.subtract([indexPath.item])
//                print("Selected items: \(self.$selections.wrappedValue) (removed \(indexPath) because item removed)")
//            }
//        }
        
        func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            // Unsure if necessary to queue:
            DispatchQueue.main.async {
                self.selections.formUnion(indexPaths.map{ $0.item })
                print("Selected items: \(self.selections) \n\t| added: \(indexPaths)")
                
                if let quickLook = QLPreviewPanel.shared() {
                    if (quickLook.isVisible) {
                        quickLook.reloadData()
                    }
                }
            }
        }
        
        func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            // Unsure if necessary to queue:
            DispatchQueue.main.async {
                self.$selections.wrappedValue.subtract(indexPaths.map{ $0.item })
                print("Selected items: \(self.$selections.wrappedValue) (removed \(indexPaths))")
                
                if let quickLook = QLPreviewPanel.shared() {
                    if (quickLook.isVisible) {
                        quickLook.reloadData()
                    }
                }
            }
        }
        
        
        
        ////////////////////////
        /// Quick look
        /// //////////////////
        
        func handleKeyDown(_ event: NSEvent) -> Bool {
            let spaceKeyCode: UInt16 = 49
            switch event {
            case _ where event.keyCode == spaceKeyCode:
                guard isQuickLookEnabled else {
                    return false
                }
                
                print("Space pressed & QuickLook is enabled.")
                if let quickLook = QLPreviewPanel.shared() {
                    quickLook.currentPreviewItemIndex = selections.sorted(by: <).first ?? 0
                    
                    print("preview idx: \(quickLook.currentPreviewItemIndex)")
                    
                    let isQuickLookShowing = QLPreviewPanel.sharedPreviewPanelExists() && quickLook.isVisible
                    
                    if (isQuickLookShowing) {
                        quickLook.reloadData()
                    } else {
                        quickLook.dataSource = self
                        quickLook.delegate = self
                        quickLook.center()
                        quickLook.makeKeyAndOrderFront(nil)
                    }
                }
                
                return true
            default:
                return false
            }
        }
        
        // QLPreviewPanelDataSource
        func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
            return isQuickLookEnabled ? items.count : 0
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
                    if (selections.count <= 1) {
                        // Forward the keydown event to the NSCollectionView, which will handle moving focus.
                        parent.collectionView.keyDown(with: event)
                        return true
                    }
                default: break
                    // no-op
                }
            }
            
            return false
        }
        
        func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
            guard isQuickLookEnabled else {
                return nil
            }
            
            guard let urls = quickLookHandler() else {
                // If no URLs, return.
                return nil
            }
            
            return urls[safe: index] as QLPreviewItem?
        }
    }
}

/////////////////////////
/// HELPERS
////////////////////////
fileprivate extension NSStackView {
    func replaceViewFor<ItemType, Content: View>(_ currentItem: ItemType, usingRenderer renderer: (_ item: ItemType) -> Content) {
        removeViewsAll()
        
        self.addView(NSHostingView(rootView: renderer(currentItem) ), in: .center)
    }
    
    private func removeViewsAll() {
        for view in self.views {
            self.removeView(view)
        }
    }
}

////////////////////////////
///QucickLook
///////////////////////////

fileprivate extension FBCollectionView.CoordinatorAndDataSource {
    var isQuickLookEnabled: Bool {
        return quickLookHandler() != nil
    }
}

extension Array {
    subscript(_ indicies: Set<Int>) -> [Element] {
        var result: [Element] = []
        
        for i in indicies {
            if i > self.startIndex && i < self.endIndex {
                result.append( self[i] )
            }
        }
        
        return result
    }
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
