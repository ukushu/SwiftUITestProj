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
    
    
    
    //NSCollectionViewDelegate
//    public func collectionView(_ collectionView: NSCollectionView, updateDraggingItemsForDrag draggingInfo: NSDraggingInfo) {
//        print("collectionView")
//    }
    
    //NSCollectionViewDelegate
//    public func collectionView(_ collectionView: NSCollectionView, draggingImageForItemsAt indexPaths: Set<IndexPath>, with event: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
//
//        NSImage(named: "square.and.arrow.down.on.square.fill")!
//    }
    
    // NSCollectionViewDelegate
    public func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt index: Int) -> NSPasteboardWriting? {
        guard let item = items[index] as? URL? else { return nil }
        
        return item as NSPasteboardWriting?
    }
    
    public func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        
        print("SupplementaryElementKind")
        
        return collectionView.item(at: indexPath.item)!.view
    }
    
    
    
//    func collectionView(collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> NSView {
//        // 1
////        let identifier: String = kind == NSCollectionElementKindSectionHeader ? "HeaderView" : ""
////        let view = collectionView.makeSupplementaryViewOfKind(kind, withIdentifier: identifier, forIndexPath: indexPath)
////        // 2
////        if kind == NSCollectionElementKindSectionHeader {
////          let headerView = view as! HeaderView
////          headerView.sectionTitle.stringValue = "Section \(indexPath.section)"
////          let numberOfItemsInSection = imageDirectoryLoader.numberOfItemsInSection(indexPath.section)
////          headerView.imageCount.stringValue = "\(numberOfItemsInSection) image files"
////        }
//
//        let identifier: String = kind == NSCollectionView.elementKindSectionHeader ? "HeaderView" : ""
////        let view = collectionView.makeSupplementaryViewOfKind(kind, withIdentifier: identifier, forIndexPath: indexPath as IndexPath)
//
////        let view = collectionView.item(at: indexPath.item)!.view
//
//        return view
//      }
    
    //////////////////////////////
    //QuickLook
    //////////////////////////////
    var quickLookHandler: ( () -> [URL]? )!
    
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
