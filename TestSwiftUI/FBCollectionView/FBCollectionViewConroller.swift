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
    
    
//    WORKS WELL
    public func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        print("collectionView shouldSelectItemsAt \(indexPaths.map{ $0.item })")
        
        if let selection = selection {
            let newSelSet = Set(indexPaths.map{ $0.item })
            
            if selection.wrappedValue != newSelSet {
                selection.wrappedValue = newSelSet
            }
        }
        
        return indexPaths
    }
    
    public func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
        print("collectionView shouldDeselectItemsAt \(indexPaths.map{ $0.item })")

//        selection?.wrappedValue.subtract(indexPaths.map{ $0.item })

//        if let selection = selection {
//            let newSelSet = selection.wrappedValue.subtracting(indexPaths.map{ $0.item })
//
//            if selection.wrappedValue != newSelSet {
//                selection.wrappedValue = newSelSet
//            }
//        }

        return indexPaths
    }

    public func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        print("collectionView didDeselectItemsAt \(indexPaths.map{ $0.item })")

//        selection?.wrappedValue.subtract(indexPaths.map{ $0.item })
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
