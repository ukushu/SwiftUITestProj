import SwiftUI
import Quartz

// TODO: ItemType extends identifiable?
// TODO: Move the delegates to a coordinator.
struct SwiftNSCollectionView<ItemType, Content: View>: /* NSObject, */ NSViewRepresentable /* NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout */ { 
    var layout: NSCollectionViewFlowLayout
    
    @Binding var items: [ItemType]
    @Binding var selectedItems: Set<Int>
    
    typealias ItemRenderer = (_ item: ItemType) -> Content
    var renderer: ItemRenderer
    
//    typealias DragHandler = (_ item: ItemType) -> NSPasteboardWriting?
//    var dragHandler: DragHandler?
//
//    typealias QuickLookHandler = (_ items: [ItemType]) -> [URL]?
//    var quickLookHandler: QuickLookHandler?
    
//    typealias ContextMenuItemsGenerator = (_ items: [ItemType]) -> [NSMenuItemProxy]
//    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
    
    init(items: Binding<[ItemType]>, selectedItems: Binding<Set<Int>>, layout: NSCollectionViewFlowLayout, renderer: @escaping (_ item: ItemType) -> Content) {
        self._items = items
        self._selectedItems = selectedItems
        self.renderer = renderer
        self.layout = layout
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, items: $items, selections: $selectedItems)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let collectionView = InternalCollectionView()
        scrollView.documentView = collectionView
        
        updateNSView(scrollView, context: context)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        
        print("Update")
        let collectionView = scrollView.documentView as! InternalCollectionView
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
//        collectionView.keyDownHandler = context.coordinator.handleKeyDown(_:)
        
        let configuration = NSCollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .vertical
        
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColors = [.clear]
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(CollectionViewCell<Content>.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("Cell"))
    }
}

//extension SwiftNSCollectionView {
//    // Just do lots of copies?
//    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-modifiers-for-a-uiviewrepresentable-struct
//    func onDrag(_ dragHandler: @escaping DragHandler) -> SwiftNSCollectionView {
//        var view = self
//        view.dragHandler = dragHandler
//        return view
//    }
//}

//extension SwiftNSCollectionView {
//    func onQuickLook(_ quickLookHandler: @escaping QuickLookHandler) -> SwiftNSCollectionView {
//        var view = self
//        view.quickLookHandler = quickLookHandler
//        return view
//    }
//}

//////////////////////////////
///HELPERS
/////////////////////////////


private final class InternalCollectionView: NSCollectionView {
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
