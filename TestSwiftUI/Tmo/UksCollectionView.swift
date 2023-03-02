import SwiftUI
import Quartz

/*
 /////////////////SwiftUI usage Sample/////////////////////////////
 
 @State var filesLst = [URL(), URL(), URL()]
 @State var selectedItems: Set<Int> = []
 
 let layout = flowLayout()
 
 UksCollectionView(items: $filesLst, selectedItems: $selectedItems, layout: layout) { item in
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
struct UksCollectionView<ItemType, Content: View>: /* NSObject, */ NSViewRepresentable /* NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout */ { 
    private let layout: NSCollectionViewFlowLayout
    private let scrollView = NSScrollView()
    let collectionView = InternalCollectionView()
    
    @Binding var items: [ItemType]
    @Binding var selectedItems: Set<Int>
    
    typealias ItemRenderer = (_ item: ItemType) -> Content
    var renderer: ItemRenderer
    
    init(items: Binding<[ItemType]>, selectedItems: Binding<Set<Int>>, layout: NSCollectionViewFlowLayout, renderer: @escaping (_ item: ItemType) -> Content) {
        self._items = items
        self._selectedItems = selectedItems
        self.renderer = renderer
        self.layout = layout
        
        self.scrollView.documentView = collectionView
    }
    
    func makeCoordinator() -> CoordinatorAndDataSource {
        CoordinatorAndDataSource(self, items: $items, selections: $selectedItems)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(CollectionViewCell<Content>.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
        
        updateNSView(scrollView, context: context)
        
        if let item = items.first, type(of: item) == URL.self {
            collectionView.keyDownHandler = context.coordinator.handleKeyDown(_:)
            print("ItemType.Type is URL")
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        print("Update")
        reload()
    }
    
    func reload() {
        // Reload the collection view data when the items array is changed.
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
    }
}

//extension UksCollectionView {
//    // Just do lots of copies?
//    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-modifiers-for-a-uiviewrepresentable-struct
//    func onDrag(_ dragHandler: @escaping DragHandler) -> UksCollectionView {
//        var view = self
//        view.dragHandler = dragHandler
//        return view
//    }
//}

//////////////////////////////
///HELPERS
/////////////////////////////

final class InternalCollectionView: NSCollectionView {
    // Return whether or not you handled the event
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
//    typealias ContextMenuItemsGenerator = (_ items: [IndexPath]) -> [NSMenuItemProxy]
//    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
//    var currentContextMenuItemProxies: [NSMenuItemProxy] = []
    
    override func keyDown(with event: NSEvent) {
        if let keyDownHandler = keyDownHandler {
            let didHandle = keyDownHandler(event)
            if (didHandle) {
                return
            }
        }
        
        super.keyDown(with: event)
    }
}
