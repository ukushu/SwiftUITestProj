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
 */

/*
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
struct FBCollectionView<ItemType, Content: View>: /* NSObject, */ NSViewRepresentable /* NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout */ {
    private let layout: NSCollectionViewFlowLayout
    let scrollView = NSScrollView()
    let collectionView = InternalCollectionView()
    
    @Binding var items: [ItemType] {
        didSet {
            self.reload()
        }
    }
    
    @Binding var selectedItems: Set<Int>
    @State var selectedItemsOld: Set<Int> = []
    
    typealias ItemRenderer = (_ item: ItemType) -> Content
    var renderer: ItemRenderer
    
    var scrollToTop: AnyPublisher<Void, Never>?
    
    init(items: Binding<[ItemType]>, selectedItems: Binding<Set<Int>>, layout: NSCollectionViewFlowLayout, scrollToTop: AnyPublisher<Void, Never>? = nil, renderer: @escaping (_ item: ItemType) -> Content) {
        
        self._items = items
        self._selectedItems = selectedItems
        self.renderer = renderer
        self.layout = layout
        self.scrollToTop = scrollToTop
        
        self.scrollView.documentView = collectionView
        
        if let superview = scrollView.superview {
            scrollView.frame = superview.frame
        }
    }
    
    func makeCoordinator() -> CoordinatorAndDataSource {
        CoordinatorAndDataSource(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator // NSCollectionViewDelegate
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = false
        
        collectionView.register(FBCollectionViewCell<Content>.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
        
        updateNSView(scrollView, context: context)
        
        if ItemType.self == URL.self || ItemType.self == RecentFile.self  {
            print("ItemType.Type is URL OR RecentFile")
            collectionView.keyDownHandler = context.coordinator.handleKeyDown(_:)
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if selectedItemsOld != selectedItems {
            selectedItemsOld = selectedItems
            self.reload()
        }
        
        
        print("Update: \n| items.count: \(items.count) \n| selectedItems: \(selectedItems) \n| collectionView.selectionIndexPaths \( collectionView.selectionIndexPaths )")
        
        reload()
    }
    
    func reload() {
        // Reload the collection view data when the items array is changed.
        DispatchQueue.main.async {
//hang UI
//            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems() )
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
