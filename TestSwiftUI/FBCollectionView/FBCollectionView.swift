import SwiftUI
import Quartz
import Combine

/*
 /////////////////SwiftUI usage Sample/////////////////////////////
 
 @State var filesLst = [URL(), URL(), URL()]
 @State var selectedItems: Set<Int> = []
 
 let layout = flowLayout()
 
 FBCollectionView(items: $filesLst, selectedItems: $selectedItems, layout: layout) { item in
     Text(item.lastPathComponent )]
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
struct FBCollectionView<ItemType, Content: View>: /* NSObject, */ NSViewControllerRepresentable /* NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout */ {
    private let layout: NSCollectionViewFlowLayout
    
    let items: [ItemType]
    let selectedItems: Set<Int>
    var scrollToTop: AnyPublisher<Void, Never>?
    
    let factory: (ItemType, IndexPath) -> Content
    
    init(items: [ItemType], selection: Set<Int>, layout: NSCollectionViewFlowLayout, factory: @escaping (ItemType, IndexPath) -> Content) {
        self.items = items
        self.selectedItems = selection
        self.layout = layout
        self.factory = factory
    }
    
    func makeNSViewController(context: Context) -> NSViewController {
        let scrollView = NSScrollView()
        let collectionView = InternalCollectionView()
        scrollView.documentView = collectionView
        
        let viewController = NSCollectionController(collection: self.items, factory: factory, selection: selectedItems)
        viewController.view = scrollView
        scrollView.documentView = collectionView
        
        collectionView.dataSource = viewController
        collectionView.delegate = viewController
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = false
        
        collectionView.register(CollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"))
        
        if ItemType.self == URL.self || ItemType.self == RecentFile.self {
            //collectionView.keyDownHandler = context.coordinator.handleKeyDown(_:)
        }
        
        return viewController
    }
    
    func updateNSViewController(_ viewController: NSViewController, context: Context) {
        guard let scrollView = viewController.view as? NSScrollView else { return }
        guard let collectionView = scrollView.documentView as? NSCollectionView else { return }
        guard let controller = viewController as? NSCollectionController<[ItemType],Content> else { return }
        
        print("Update: \n| items.count: \(items.count) \n| selectedItems: \(selectedItems) \n| collectionView.selectionIndexPaths \( collectionView.selectionIndexPaths )")
        
        controller.collection = self.items
        
        collectionView.reloadData()
    }
        
}

//extension FBCollectionView {
//    // Just do lots of copies?
//    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-modifiers-for-a-uiviewrepresentable-struct
//    func onDrag(_ dragHandler: @escaping DragHandler) -> FBCollectionView {
//        var view = self
//        view.dragHandler = dragHandler
//        return view
//    }
//}

//////////////////////////////
///HELPERS
/////////////////////////////

final class InternalCollectionView: NSCollectionView {
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    override func keyDown(with event: NSEvent) {
        if let keyDownHandler = keyDownHandler {
            let didHandle = keyDownHandler(event)
            if (didHandle) {
                return
            }
        }
        
        super.keyDown(with: event)
    }
    
    ////////////////////////////////////////////////////////////////////
//    typealias ContextMenuItemsGenerator = (_ items: [IndexPath]) -> [NSMenuItemProxy]
//    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
//    var currentContextMenuItemProxies: [NSMenuItemProxy] = []
}
