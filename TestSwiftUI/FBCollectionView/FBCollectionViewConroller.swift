import Foundation
import Cocoa
import SwiftUI
import AppKit

public class NSCollectionController<T: RandomAccessCollection, Content: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource
        where T.Index == Int {

    let factory: (T.Element,IndexPath) -> Content
    
    let         id : String
    let         collection : T
    weak var    collectionView: NSCollectionView?
    let         selection : Set<Int>?
    
    init(id: String, collection: T, factory: @escaping (T.Element, IndexPath) -> Content, collectionView: NSCollectionView? = nil, selection: Set<Int>?) {
        self.id = id
        self.collection = collection
        self.factory = factory
        self.collectionView = collectionView
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        fatalError()
        //collectionView.register(FBCollectionViewCell<NSCollectionView>.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
//        collectionView.makeItem(withIdentifier: <#T##NSUserInterfaceItemIdentifier#>, for: <#T##IndexPath#>)
    }
    
    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        collection.count
    }
    
//    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSView {
//        NSHostingView(rootView: factory(collection[indexPath.item],indexPath))
//    }
}


