import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine
import Quartz

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
//QuickLook
, QLPreviewPanelDataSource
where T.Index == Int {
    
    let factory: (T.Element, IndexPath) -> Content
    
    let         id : String
    var         items : T
    weak var    itemsView: NSCollectionView?
    let         selection : Binding<IndexSet>
    
    //    public let parent: NSCollectionView
    
    let scrollToTopCancellable: AnyCancellable?
    
    init(id: String = "", collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, selection: Binding<IndexSet>, scrollToTopCancellable: AnyCancellable?) {
        print("Controller init")
        
        self.id = id
        self.items = collection
        self.factory = factory
        self.itemsView = collectionView
        self.selection = selection
        self.scrollToTopCancellable = scrollToTopCancellable
        
        super.init(nibName: nil, bundle: nil)
        
        self.quickLookHandler = { [weak self] in self?.items.compactMap{ $0 as? URL } ?? []  }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return makeItemForCV(byIndexPath: indexPath, collectionView: collectionView)
    }
    
    func makeItemForCV(byIndexPath indexPath: IndexPath, collectionView: NSCollectionView) -> NSCollectionViewItem {
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
#if true // HELPERS Selection update
    ///////////////////////////////
    
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        print("shouldSelectItemsAt: \(indexPaths.map{ $0.intValue })")
        
        collectionView.selectionIndexes = collectionView.selectionIndexes.union( IndexSet(indexPaths.map{ $0.intValue } ) )
        print("sel: \(collectionView.selectionIndexes.map{ $0 as Int })" )
        print("sel2: \(self.selection.wrappedValue.map{$0} )" )
        
        return indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        print("SHOULD_DeselectItemsAt: \(indexPaths.map{ $0.intValue })")
        
        collectionView.selectionIndexes = collectionView.selectionIndexes.subtracting( IndexSet(indexPaths.map{ $0.intValue } ) )
        print("sel: \(collectionView.selectionIndexes.map{ $0})" )
        print("sel2: \(self.selection.wrappedValue.map{ $0})" )
        
        return indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
//        collectionView.becomeFirstResponder()
    }
#endif
    
    ///////////////////////////////
    // HELPERS Drag
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        print("collectionView")
    }
    
    public func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        NSImage(named: "square.and.arrow.down.on.square.fill")!
    }
    
    // NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        print("check for dragHandler is not nil")
        
        guard let itemsView = self.itemsView as? FBCollectionView<URL, FileTile>?,
              let dragHandler = itemsView?.dragHandler,
              let item = itemsView?.items[index]
        else { return nil }
        
        print("dragHandler is not nil!!!!!")
        
        return dragHandler(item)
    }
    
    ///////////////////////////////
    // HELPERS
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //////////////////////////////
    //QuickLook
    //////////////////////////////
    var quickLookHandler: ( () -> [URL]? )!
    
    func handleKeyDown(_ event: NSEvent) -> Bool {
        let spaceKeyCode: UInt16 = 49
        switch event {
        case _ where event.keyCode == spaceKeyCode:
            guard isQuickLookEnabled else {
                return false
            }
            
            print("Space pressed & QuickLook is enabled.")
            if let quickLook = QLPreviewPanel.shared() {
                quickLook.currentPreviewItemIndex = selection.wrappedValue.sorted(by: <).first ?? 0
                
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
    public func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int {
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
                // Don't pass through shift-selection keys.
                guard event.modifierFlags.contains(.shift) == false else { return false }
                
                // Though I believe the event is handled by QL when
                // multiple items exist, just be safe.
                if (selection.wrappedValue.count <= 1) {
                    // Forward the keydown event to the NSCollectionView, which will handle moving focus.
                    
                    parent?.keyDown(with: event)
                    return true
                }
            default: break
                // no-op
            }
        }
        
        return false
    }
    
    public func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! {
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

fileprivate extension NSCollectionController {
    var isQuickLookEnabled: Bool {
        return quickLookHandler() != nil
    }
}
