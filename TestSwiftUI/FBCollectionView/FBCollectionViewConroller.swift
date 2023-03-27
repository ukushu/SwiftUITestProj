import Foundation
import Cocoa
import SwiftUI
import AppKit

public class NSCollectionController<T: RandomAccessCollection, RowView: View>:
    NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource where T.Index == Int {
    

    let         id : String
    let         collection : T
    let         factory: (T.Element, IndexPath) -> RowView
    weak var    tableView: NSTableView?
    let         selection : Set<Int>?
    
    init(id: String, collection: T, factory: @escaping (T.Element, IndexPath) -> RowView, tableView: NSTableView? = nil, selection: Set<Int>?) {
        self.id = id
        self.collection = collection
        self.factory = factory
        self.tableView = tableView
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


