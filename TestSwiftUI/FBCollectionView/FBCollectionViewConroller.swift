import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
    where T.Index == Int, T.Element : Identifiable {
    
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
        
        if let item = item as? CollectionViewItem<T.Element.ID> {
            let element = collection[indexPath.item] //as? Identifiable
            
            print("/n--------------------")
            print(element.id, item.id)
            print("/n--------------------")
            
            if item.id != nil && item.id == element.id {
                // do nothing
            } else {
                let hosting = NSHostingView(rootView: factory(element, indexPath))
                
                item.container.views.forEach { item.container.removeView($0) }
                item.container.addView(hosting, in: .center)
                item.id = element.id
            }
        }
        
        return item
    }
        
    ///////////////////////////////
    // HELPERS Selection update
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        if let selection = selection {
            let tmp: [Int] = collectionView.selectionIndexes.sorted()
            let newSelSet: Set<Int> = Set(tmp).union(indexPaths.map{ $0.intValue })
            
            if selection.wrappedValue != newSelSet {
                selection.wrappedValue = newSelSet
            }
        }
        
        return indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        if let selection = selection {
            let tmp: [Int] = collectionView.selectionIndexes.sorted()
            let newSelSet: Set<Int> = Set(tmp).subtracting(indexPaths.map{ $0.intValue })
            
            if selection.wrappedValue != newSelSet {
                selection.wrappedValue = newSelSet
            }
        }
        
        return indexPaths
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
