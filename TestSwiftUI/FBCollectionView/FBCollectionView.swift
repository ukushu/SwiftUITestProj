import SwiftUI
import Quartz
import Combine

/*
 /////////////////SwiftUI usage Sample/////////////////////////////
 
 var filesLst = [URL(), URL(), URL()]
 var selection: Set<Int> = []
 
 let layout = flowLayout()
 
 FBCollectionView(items: model.filesList,
                  selection: model.selection,
                  layout: model.layout,
                  topScroller: model.topScroller.eraseToAnyPublisher()
 ) { item, indexPath in
     
     AppTile(app: item, isSelected: model.selection.contains(indexPath.intValue) )
     
 }
 
 
 
 
/////////////////FlowLayout Sample/////////////////////////////
 
 func flowLayout() -> NSCollectionViewFlowLayout{
     let flowLayout = NSCollectionViewFlowLayout()
             flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
             flowLayout.sectionInset = NSEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
             flowLayout.minimumInteritemSpacing = 20.0
             flowLayout.minimumLineSpacing = 20.0
             flowLayout.sectionHeadersPinToVisibleBounds = true
     
     return flowLayout
 }
 */

// TODO: ItemType extends identifiable?
// TODO: Move the delegates to a coordinator.
struct FBCollectionView<ItemType: Hashable, Content: View>: NSViewControllerRepresentable /* NSObject, NSCollectionViewDelegateFlowLayout */ {
    
    //Need to locate here for topScroller
    var scrollView: NSScrollView = NSScrollView()
    
    private let layout: NSCollectionViewFlowLayout
    
    let items: [ItemType]
    var selection : IndexSet { CollectionState.shared.selection }
    
    let topScroller: AnyPublisher<Void, Never>?
    
    let factory: (ItemType, IndexPath) -> Content
    
    init(items: [ItemType], layout: NSCollectionViewFlowLayout, topScroller: AnyPublisher<Void, Never>? = nil, factory: @escaping (ItemType, IndexPath) -> Content) {
        self.items = items
        self.layout = layout
        self.topScroller = topScroller
        self.factory = factory
    }
    
    func makeNSViewController(context: Context) -> NSViewController {
        let collectionView = InternalCollectionView()
        
        let viewController = NSCollectionController(collection: self.items,
                                                    factory: factory,
                                                    scrollToTopCancellable: getScrollToTopCancellable() )
        
        viewController.view = scrollView
        collectionView.dataSource = viewController
        collectionView.delegate = viewController
        
        scrollView.documentView = collectionView
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.canDrawConcurrently = true
        
        collectionView.register(FBCItemView.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"))
        
        collectionView.keyDownHandler = viewController.handleKeyDown(_:)
        
        initDragAndDrop(collectionView)
        
        return viewController
    }
    
    func updateNSViewController(_ viewController: NSViewController, context: Context) {
        guard let scrollView = viewController.view as? NSScrollView else { return }
        guard let collectionView = scrollView.documentView as? NSCollectionView else { return }
        guard let controller = viewController as? NSCollectionController<[ItemType],Content> else { return }
        
        collectionView.dataSource = controller
        collectionView.delegate = controller
        
        print("""
              updateNSViewController: selInternal: \(collectionView.selectionIndexes.map{ $0 }) | selExternal: \(self.selection.map{ $0 })
              """ )
        
        collectionView.selectionIndexes = selection
        
//        print("Update: \n| items.count: \(items.count) \n| selection: \(String(describing: selection?.wrappedValue)) \n| collectionView.selectionIndexPaths \( collectionView.selectionIndexPaths )")
        
//        let itemsToUpd = Set(controller.collection).subtracting(self.items)
        
//        let idxToUpd = controller.collection.filter{ itemsToUpd.contains($0) }.indices.map{ IndexPath(index: $0) }
//        
//        let selections = self.selection?.wrappedValue.map{ IndexPath(index: $0) } ?? []
        
        if controller.items == self.items {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
        } else {
            controller.items = self.items
            collectionView.reloadData()
        }
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        print("updateNSView")
    }
}

//////////////////////////////
///HELPERS
/////////////////////////////


