import Foundation
import Cocoa
import SwiftUI
import AppKit
import Combine

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
        where T.Index == Int {
    
    let factory: (T.Element,IndexPath) -> Content
    
    let         id : String
    var         collection : T
    weak var    collectionView: NSCollectionView?
    let         selection : Set<Int>?
    
    let scrollToTopCancellable: AnyCancellable?
    
    init(id: String = "", collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, selection: Set<Int>?, scrollToTopCancellable: AnyCancellable?) {
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
            let hosting = NSHostingView(rootView: factory(collection[indexPath.item],indexPath))
            
            item.container.views.forEach { item.container.removeView($0) }
            item.container.addView(hosting, in: .center)
        }
        
        return item
    }
    
    
    
    
    
    
    ///////////////////////////////
    // HELPERS
    ///////////////////////////////
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int { collection.count }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
