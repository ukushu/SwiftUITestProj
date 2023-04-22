import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine
import Quartz

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
//QuickLook
//    ,
//    QLPreviewPanelDataSource
        where T.Index == Int {
    
    let factory: (T.Element, IndexPath) -> Content
    
    let         id : String
    var         items : T
    weak var    itemsView: NSCollectionView?
    let         selection : Binding<Set<Int>>?
    
//    public let parent: NSCollectionView
    
    let scrollToTopCancellable: AnyCancellable?
    
            init(id: String = "", collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, selection: Binding<Set<Int>>?, scrollToTopCancellable: AnyCancellable?) {
        self.id = id
        self.items = collection
        self.factory = factory
        self.itemsView = collectionView
        self.selection = selection
        self.scrollToTopCancellable = scrollToTopCancellable
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"), for: indexPath)
        
        if let item = item as? CollectionViewItem {
            let hosting = NSHostingView(rootView: factory(items[indexPath.item], indexPath))
            
            item.container.views.forEach { item.container.removeView($0) }
            item.container.addView(hosting, in: .center)
        }
        
        return item
    }
    
//    public func reloadData(at indexPath: Set<IndexPath>? ) {
//        if let indexPath = indexPath {
//            collectionView?.reloadItems(at: indexPath)
//        }
//
//        if let selection = selection {
//            if selection.wrappedValue.isEmpty && collection.count > 0 {
//                selection.wrappedValue = [0]
//            }
//        }
//    }
    
    
    
    
    
    ///////////////////////////////
    // HELPERS Selection update
    ///////////////////////////////
    
//    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//        // Unsure if necessary to queue:
//        DispatchQueue.main.async {
//            self.selection?.wrappedValue.formUnion(indexPaths.map{ $0.item })
////            print("Selected items: \(self.selections) \n\t| added: \(indexPaths)")
//
////            if let quickLook = QLPreviewPanel.shared() {
////                if (quickLook.isVisible) {
////                    quickLook.reloadData()
////                }
////            }
//        }
//    }
    
    public override func viewDidAppear() {
        //Select first item if selection is empty
        guard let selection = selection else { return }
        if items.count > 0 && selection.wrappedValue.count == 0
        {
            selection.wrappedValue = [0]
            becomeFirstResponder()
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
//        if let sel = self.selection?.wrappedValue {
//            print("+ shouldSelectItemsAt\nAdded: \(indexPaths)\n\tSelected items: \(sel)")
//        }
        
        guard let items = self.items as? [URL?] else { return indexPaths}
        
        
        // do not select nil items
        return indexPaths.filter{ items[$0.intValue] != nil }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        if let sel = self.selection?.wrappedValue {
            print("+ didSelectItemsAt\nAdded: \(indexPaths)\n\tSelected items: \(sel)")
        }
        
        if let selection = selection {
            let newSelSet: Set<Int> = Set(indexPaths.map{ $0.item })
//            let newSelSet: Set<Int> = selection.wrappedValue.union(indexPaths.map{ $0.item }) //.union(indexPaths.map{ $0 })
            
            if selection.wrappedValue != newSelSet {
                selection.wrappedValue = newSelSet
            }
            
//            collectionView.selectItems(at: indexPaths, scrollPosition: .nearestHorizontalEdge)
            
        }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
//        if let sel = self.selection?.wrappedValue {
//            print("- shouldDeselectItemsAt\nRemoved: \(indexPaths)\n\tSelected items: \(sel)")
//        }
        
        guard let items = self.items as? [URL?] else { return indexPaths}
        
        // do not select nil items
        return indexPaths.filter{ items[$0.intValue] != nil }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        //select fisrt if nothing selected #1
//        let firstSel = self.selection?.wrappedValue.first ?? 0
        
        if let sel = self.selection?.wrappedValue {
            print("- didDeselectItemsAt\nRemoved: \(indexPaths)\n\tSelected items: \(sel)")
        }
        
        if let selection = selection {
            if let sel = self.itemsView?.selectionIndexes.map({ $0 as Int }) {
                self.selection?.wrappedValue = Set(sel)
            }
//            let filteredSet: Set<Int> = selection.wrappedValue.subtracting(indexPaths.map{ $0.item })
//
//            if selection.wrappedValue != filteredSet {
//                selection.wrappedValue = filteredSet
//            }
//
//            //select fisrt if nothing selected #2
//            if selection.wrappedValue.isEmpty && collection.count > 0 {
//                selection.wrappedValue = [firstSel]
//            }
        }
        
        collectionView.becomeFirstResponder()
    }
    
    ///////////////////////////////
    // HELPERS Drag
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        print("collectionView")
    }
    
    public func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        NSImage(named: "square.and.arrow.down.on.square.fill")!
    }
    
    ///////////////////////////////
    // HELPERS
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
//    //////////////////////////////
//    //QuickLook
//    //////////////////////////////
//    var quickLookHandler: ( () -> [URL]? )!
//
//    func handleKeyDown(_ event: NSEvent) -> Bool {
//        let spaceKeyCode: UInt16 = 49
//        switch event {
//        case _ where event.keyCode == spaceKeyCode:
//            guard isQuickLookEnabled else {
//                return false
//            }
//
//            print("Space pressed & QuickLook is enabled.")
//            if let quickLook = QLPreviewPanel.shared() {
//                quickLook.currentPreviewItemIndex = selection?.wrappedValue.sorted(by: <).first ?? 0
//
//                print("preview idx: \(quickLook.currentPreviewItemIndex)")
//
//                let isQuickLookShowing = QLPreviewPanel.sharedPreviewPanelExists() && quickLook.isVisible
//
//                if (isQuickLookShowing) {
//                    quickLook.reloadData()
//                } else {
//                    quickLook.dataSource = self
//                    quickLook.delegate = self
//                    quickLook.center()
//                    quickLook.makeKeyAndOrderFront(nil)
//                }
//            }
//
//            return true
//        default:
//            return false
//        }
//    }
//
//    // QLPreviewPanelDataSource
//    public func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
//        return isQuickLookEnabled ? items.count : 0
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
//                // Don't pass through shift-selection keys.
//                guard event.modifierFlags.contains(.shift) == false else { return false }
//
//                // Though I believe the event is handled by QL when
//                // multiple items exist, just be safe.
//                if (selection?.wrappedValue.count ?? 0 <= 1) {
//                    // Forward the keydown event to the NSCollectionView, which will handle moving focus.
//
//                    parent?.keyDown(with: event)
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
//    public func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
//        guard isQuickLookEnabled else {
//            return nil
//        }
//
//        guard let urls = quickLookHandler() else {
//            // If no URLs, return.
//            return nil
//        }
//
//        return urls[safe: index] as QLPreviewItem?
//    }
}

//fileprivate extension NSCollectionController {
//    var isQuickLookEnabled: Bool {
//        return quickLookHandler() != nil
//    }
//}
