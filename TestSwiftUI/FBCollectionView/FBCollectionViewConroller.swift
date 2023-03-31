import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
        where T.Index == Int {
    
    let factory: (T.Element, IndexPath) -> Content
    
    let         id : String
    var         collection : T
    weak var    collectionView: NSCollectionView?
    let         selection : Binding<Set<Int>>?
    
    let scrollToTopCancellable: AnyCancellable?
    
    init(id: String = "", collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, selection: Binding<Set<Int>>?, scrollToTopCancellable: AnyCancellable?) {
        self.id = id
        self.collection = collection
        self.factory = factory
        self.collectionView = collectionView
        self.selection = selection
        self.scrollToTopCancellable = scrollToTopCancellable
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"), for: indexPath)
        
        if let item = item as? CollectionViewItem {
            let hosting = NSHostingView(rootView: factory(collection[indexPath.item], indexPath))
            
            item.container.views.forEach { item.container.removeView($0) }
            item.container.addView(hosting, in: .center)
        }
        
        return item
    }
    
    ///////////////////////////////
    // HELPERS Selection update
    ///////////////////////////////
    
    public func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print("collectionView didSelectItemsAt ")
        
//        selection?.wrappedValue = Set( collectionView.selectionIndexes )
        updSelectionIfNeeded(collectionView)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        print("collectionView didDeselectItemsAt ")
        
//        selection?.wrappedValue = Set( collectionView.selectionIndexes )
        updSelectionIfNeeded(collectionView)
    }
    
    func updSelectionIfNeeded(_ collectionView: NSCollectionView) {
        guard let selection = selection else { return }
        
        let selSet: Set<Int> = Set( collectionView.selectionIndexes )
        
        if selection.wrappedValue != selSet {
            selection.wrappedValue = selSet
        }
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
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { collection.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
