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
struct FBCollectionView<ItemType: Hashable, Content: View>: /* NSObject, */ NSViewControllerRepresentable /* NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout */ {
    
    //Need to locate here for topScroller
    private var scrollView: NSScrollView = NSScrollView()
    
    private let layout: NSCollectionViewFlowLayout
    
    let items: [ItemType]
    var selection: Binding<Set<Int>>?
    
    let topScroller: AnyPublisher<Void, Never>?
    
    let factory: (ItemType, IndexPath) -> Content
    
    init(items: [ItemType], selection: Binding<Set<Int>>?, layout: NSCollectionViewFlowLayout, topScroller: AnyPublisher<Void, Never>? = nil, factory: @escaping (ItemType, IndexPath) -> Content) {
        
        self.items = items
        self.selection = selection
        self.layout = layout
        self.topScroller = topScroller
        self.factory = factory
    }
    
    func makeNSViewController(context: Context) -> NSViewController {
        let collectionView = InternalCollectionView()
        
        let viewController = NSCollectionController(collection: self.items,
                                                    factory: factory,
                                                    selection: selection,
                                                    scrollToTopCancellable: getScrollToTopCancellable() )
        
        
        viewController.view = scrollView
        collectionView.dataSource = viewController
        collectionView.delegate = viewController
        
        scrollView.documentView = collectionView
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = false
        
        collectionView.register(CollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("NSCollectionViewItem"))
        
//        if ItemType.self == URL.self {
//            collectionView.keyDownHandler = context.coordinator.handleKeyDown(_:)
//        }
        
        return viewController
    }
    
    func updateNSViewController(_ viewController: NSViewController, context: Context) {
        guard let scrollView = viewController.view as? NSScrollView else { return }
        guard let collectionView = scrollView.documentView as? NSCollectionView else { return }
        guard let controller = viewController as? NSCollectionController<[ItemType],Content> else { return }
        
//        print("Update: \n| items.count: \(items.count) \n| selection: \(String(describing: selection?.wrappedValue)) \n| collectionView.selectionIndexPaths \( collectionView.selectionIndexPaths )")
        
//        let itemsToUpd = Set(controller.collection).subtracting(self.items)
        
//        let idxToUpd = controller.collection.filter{ itemsToUpd.contains($0) }.indices.map{ IndexPath(index: $0) }
//        
//        let selections = self.selection?.wrappedValue.map{ IndexPath(index: $0) } ?? []
        
        if controller.collection == self.items {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
        } else {
            controller.collection = self.items
            collectionView.reloadData()
        }
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
extension FBCollectionView {
    func getScrollToTopCancellable() -> AnyCancellable? {
        topScroller?.sink { [self] _ in
            print("scrolling to top")
            
            DispatchQueue.main.async {
                scrollView.documentView?.scroll(.zero)
            }
        }
    }
}

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
    
    override func becomeFirstResponder() -> Bool {
        if selectionIndexPaths.count == 0 {
            for section in 0..<numberOfSections {
                if numberOfItems(inSection: section) > 0 {
                    selectionIndexPaths = [IndexPath(item: 0, section: section)]
                    break
                }
            }
        }
        return super.becomeFirstResponder()
    }
    
    ////////////////////////////////////////////////////////////////////
//    typealias ContextMenuItemsGenerator = (_ items: [IndexPath]) -> [NSMenuItemProxy]
//    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
//    var currentContextMenuItemProxies: [NSMenuItemProxy] = []
}

public extension IndexPath {
    var intValue: Int {
        self.item
    }
}
