import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine
import Quartz

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
//QuickLook
, QLPreviewPanelDataSource, QLPreviewPanelDelegate
where T.Index == Int {
    
    let factory: (T.Element, IndexPath) -> Content
    
    let         id : String
    var         items : T
    weak var    collectionView: NSCollectionView?
    var         selection : IndexSet {
        get { CollectionState.shared.selection }
        set { CollectionState.shared.selection = newValue }
    }
    
    let scrollToTopCancellable: AnyCancellable?
    
    init(id: String = "", collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, scrollToTopCancellable: AnyCancellable?) {
        print("Controller init")
        
        self.id = id
        self.items = collection
        self.factory = factory
        self.collectionView = collectionView
        self.scrollToTopCancellable = scrollToTopCancellable
        
        super.init(nibName: nil, bundle: nil)
        
        self.quickLookHandler = { [weak self] in self?.items.compactMap{ $0 as? URL } ?? []  }
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return makeItemForCV(byIndexPath: indexPath, collectionView: collectionView)
    }
    
    
    ///////////////////////////////
    // HELPERS Selection update
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        selectionLog("________________", indexPaths, collectionView)
        self.selection = collectionView.selectionIndexes
        selectionLog("didSelectItemsAt", indexPaths, collectionView)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        selectionLog("_______________", indexPaths, collectionView)
        self.selection = collectionView.selectionIndexes
        selectionLog("DESELECTItemsAt", indexPaths, collectionView)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return exceptNilItems(indexPaths)
    }
    
    ///////////////////////////////
    // HELPERS Drag
    ///////////////////////////////
    ///
    //NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
        print("collectionView")
    }
    
    //NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        
        NSImage(named: "square.and.arrow.down.on.square.fill")!
    }
    
    // NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        print("check for dragHandler is not nil")
        
        guard let collectionView = self.collectionView as? FBCollectionView<URL, FileTile>?,
              let dragHandler = collectionView?.dragHandler,
              let item = collectionView?.items[index]
        else { return nil }
        
        print("dragHandler is not nil!!!!!")
        
        return dragHandler(item)
    }
    
    //////////////////////////////
    //QuickLook
    //////////////////////////////
    var quickLookHandler: ( () -> [URL]? )!
    
    func handleKeyDown(_ event: NSEvent) -> Bool {
        let spaceKeyCode: UInt16 = 49
        switch event {
        case _ where event.keyCode == spaceKeyCode:
            guard isQuickLookEnabled else { return false }
            
            enableQuickLookPanel()
            
            return true
        default:
            return false
        }
    }
    
    // QLPreviewPanelDataSource
    public func numberOfPreviewItems(in panel: QLPreviewPanel!) -> Int { isQuickLookEnabled ? items.count : 0 }
    
    // QLPreviewPanelDelegate               | Inspired by https://stackoverflow.com/a/33923618/788168
    public func previewPanel(_ panel: QLPreviewPanel!, handle event: NSEvent!) -> Bool { quickLookKeyboardArrowsController(event: event) }
    
    //QLPreviewPanelDataSource
    public func previewPanel(_ panel: QLPreviewPanel!, previewItemAt index: Int) -> QLPreviewItem! { previewItemAt(index: index) }
    
    ///////////////////////////////
    // HELPERS
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

////////////////////////
///QuickLook
////////////////////////
fileprivate extension NSCollectionController {
    var isQuickLookEnabled: Bool { quickLookHandler() != nil }
    
    var isQuickLookShowing: Bool { QLPreviewPanel.sharedPreviewPanelExists() && (QLPreviewPanel.shared()?.isVisible ?? false) }
    
    func previewItemAt(index: Int) -> QLPreviewItem? {
        guard isQuickLookEnabled else { return nil }
        
        // If no URLs, return.
        guard let urls = quickLookHandler() else { return nil }
        
        self.selection = [index-1]
        
        return urls[safe: index] as QLPreviewItem?
    }
    
    func quickLookKeyboardArrowsController(event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return false }
        
        print("Key down: \(event.keyCode); modifiders: \(event.modifierFlags)")
        
        switch event.keyCode {
        case FBKey.upArrow: fallthrough
        case FBKey.rightArrow: fallthrough
        case FBKey.downArrow: fallthrough
        case FBKey.leftArrow:
            // Don't pass through shift-selection keys
            guard event.modifierFlags.contains(.shift) == false else { return false }
            // Don't pass through command-selection keys
            guard event.modifierFlags.contains(.command) == false else { return false }
            
            // Though I believe the event is handled by QL when
            // multiple items exist, just be safe.
            //if selection.count <= 1 {
                // Forward the keydown event to the NSCollectionView, which will handle moving focus.
                collectionView?.keyDown(with: event)
                return true
//            }
        default:
            break
        }
        
        return false
    }
    
    func enableQuickLookPanel() {
        print("Space pressed & QuickLook is enabled.")
        
        guard let quickLook = QLPreviewPanel.shared() else { return }
        
        quickLook.currentPreviewItemIndex = selection.sorted(by: <).first ?? 0
        
        print("preview idx: \(quickLook.currentPreviewItemIndex)")
        
        if isQuickLookShowing {
            quickLook.reloadData()
        } else {
            quickLook.dataSource = self
            quickLook.delegate = self
            quickLook.center()
            quickLook.makeKeyAndOrderFront(nil)
        }
    }
}

struct FBKey {
    static let upArrow: UInt16 = 126
    static let rightArrow: UInt16 = 124
    static let downArrow: UInt16 = 125
    static let leftArrow: UInt16 = 123
}

fileprivate extension NSCollectionController {
    func reloadVisibles() {
        guard let collectionView = collectionView else { return }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
    }
    
    func urlIsNilBy(_ indexPath: IndexPath) -> Bool {
        guard let url = items[indexPath.intValue] as? URL? else { return false }
        return url == nil
    }
    
    func exceptNilItems(_ indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        guard let items = self.items as? [URL?] else { return indexPaths }
        
        return indexPaths.filter{ items[$0.intValue] != nil }
    }
    
    func selectionLog(_ title: String, _ indexPaths: Set<IndexPath>, _ collectionView: NSCollectionView) {
//        print("""
//              \(title):\t changes: \(indexPaths.map{ $0.intValue })\t|\tselInternal: \(collectionView.selectionIndexes.map{ $0 })\t|\tselExternal: \(self.selection.map{ $0 })
//              """ )
    }
    
//    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
//        return indexPaths
//    }
    
    func makeItemForCV(byIndexPath indexPath: IndexPath, collectionView: NSCollectionView) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"), for: indexPath)
        
        if let item = item as? CollectionViewItem {
            let hosting = NSHostingView(rootView: factory(items[indexPath.item], indexPath))
            
            item.container.views.forEach { item.container.removeView($0) }
            item.container.addView(hosting, in: .center)
            
//            if urlIsNilBy(indexPath) {
//                item.acceptsMouseDown = false
//            }
        }
        
        return item
    }
}
