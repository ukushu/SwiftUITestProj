import SwiftUI
import Combine
import Quartz

public class FBCollectionViewConroller<Content: View>:
                    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
                    //QuickLook
                    , QLPreviewPanelDataSource, QLPreviewPanelDelegate
{
    
    let factory: (URL?, IndexPath) -> Content
    
    let         id : String
    var         items : [URL?]
    weak var    collectionView: NSCollectionView?
    var         selection : IndexSet {
        get { CollectionState.shared.selection }
        set { CollectionState.shared.setSelection(newValue) }
    }
    
    let scrollToTopCancellable: AnyCancellable?
    
    init(id: String = "", collection: [URL?], factory: @escaping (URL?, IndexPath) -> Content, collectionView: NSCollectionView, scrollToTopCancellable: AnyCancellable?) {
        self.id = id
        self.items = collection
        self.factory = factory
        self.collectionView = collectionView
        self.scrollToTopCancellable = scrollToTopCancellable
        
        super.init(nibName: nil, bundle: nil)
        
        self.quickLookHandler = { [weak self] in self?.items.compactMap{ $0 } }
        
        CollectionState.shared.setSelection(collectionView.selectionIndexes)
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
    
    var shiftIsPressed: Bool { NSEvent.modifierFlags.check(equals: .shift) }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        if shiftIsPressed {
            let itemsToAdd = shiftIsPressedItemsToAdd(collectionView, indexPaths: indexPaths)
            
            return exceptNilItems(indexPaths).union(itemsToAdd)
        }
        
        return exceptNilItems(indexPaths)
    }
    
    ///////////////////////////////
    // HELPERS Drag
    ///////////////////////////////
    
    // NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        return items[index] as? NSURL
    }
    
    // This function is called when the user starts dragging an item.
    // We return our custom pasteboard writer, which also conforms to NSDraggingSource, for the dragged item.
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        FBCollectionPasteboardWriter()
    }
    
    public func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        preventHidingDuringDrag(collectionView)
    }
    
    //////////////////////////////
    //QuickLook
    //////////////////////////////
    var quickLookHandler: ( () -> [URL]? )!
    
    // QLPreviewPanelDataSource
    public func numberOfPreviewItems(in panel: QLPreviewPanel) -> Int { isQuickLookEnabled ? quickLookHandler()?.count ?? 0 : 0 }
    
    // QLPreviewPanelDelegate               | Inspired by https://stackoverflow.com/a/33923618/788168
    public func previewPanel(_ panel: QLPreviewPanel, handle event: NSEvent) -> Bool { quickLookKeyboardArrowsController(event: event) }
    
    //QLPreviewPanelDataSource
    public func previewPanel(_ panel: QLPreviewPanel, previewItemAt index: Int) -> QLPreviewItem! { previewItemAt(index: index) }
    
    ///////////////////////////////
    // HELPERS
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { items.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

fileprivate extension FBCollectionViewConroller {
    func reloadVisibles() {
        guard let collectionView = collectionView else { return }
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
    }
    
    func urlIsNilBy(_ indexPath: IndexPath) -> Bool {
        return items[indexPath.intValue] == nil
    }
    
    func exceptNilItems(_ indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        return indexPaths.filter{ items[$0.intValue] != nil }
    }
    
    func makeItemForCV(byIndexPath indexPath: IndexPath, collectionView: NSCollectionView) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"), for: indexPath)
        
        if let item = item as? FBCItemView {
            let hosting = NSHostingView(rootView: factory(items[indexPath.item], indexPath))
            
            item.container.views.forEach { item.container.removeView($0) }
            item.container.addView(hosting, in: .center)
            item.container.addView(hosting, in: .center)
            
            item.url = items[indexPath.item]
//            if urlIsNilBy(indexPath) {
//                item.acceptsMouseDown = false
//            }
        }
        
        return item
    }
}

fileprivate extension FBCollectionViewConroller {
    func selectionLog(_ title: String, _ indexPaths: Set<IndexPath>, _ collectionView: NSCollectionView) {
//        print("""
//              \(title):\t changes: \(indexPaths.map{ $0.intValue })\t|\tselInternal: \(collectionView.selectionIndexes.map{ $0 })\t|\tselExternal: \(self.selection.map{ $0 })
//              """ )
    }
    
//    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
//        return indexPaths
//    }
}

fileprivate extension NSView {
    func asNSImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else { return nil }
        
        cacheDisplay(in: bounds, to: rep)
        
        guard let cgImage = rep.cgImage else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
}
