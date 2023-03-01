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
    
    typealias DragHandler = (_ item: ItemType) -> NSPasteboardWriting?
    var dragHandler: DragHandler?
    
//    typealias QuickLookHandler = (_ items: [ItemType]) -> [URL]?
//    var quickLookHandler: QuickLookHandler?
    
//    typealias ContextMenuItemsGenerator = (_ items: [ItemType]) -> [NSMenuItemProxy]
//    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
    
    var collectionView: NSCollectionView? = nil
    
    init(items: Binding<[ItemType]>, selectedItems: Binding<Set<Int>>, layout: NSCollectionViewFlowLayout, renderer: @escaping (_ item: ItemType) -> Content) {
        self._items = items
        self._selectedItems = selectedItems
        self.renderer = renderer
        self.layout = layout
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, selectedItems: $selectedItems)
    }
    
    typealias NSViewType = NSScrollView
    
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
        // self.collection = collectionView
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        
        // Drag and drop
        // https://www.raywenderlich.com/1047-advanced-collection-views-in-os-x-tutorial#toc-anchor-011
        if (dragHandler != nil) {
            collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
        }
        
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

extension SwiftNSCollectionView {
    // Just do lots of copies?
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-modifiers-for-a-uiviewrepresentable-struct
    func onDrag(_ dragHandler: @escaping DragHandler) -> SwiftNSCollectionView {
        var view = self
        view.dragHandler = dragHandler
        return view
    }
}

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

final class CollectionViewCell<Content: View>: NSCollectionViewItem {
    var selectedCGColor: CGColor { NSColor.selectedControlColor.cgColor }
    var nonSelectedCGColor: CGColor { NSColor.clear.cgColor }
    
    // TODO: also highlight/hover state!
    // TODO: pass to Content
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderColor = selectedCGColor
                view.layer?.borderWidth = 3
            } else {
                view.layer?.borderColor = nonSelectedCGColor
                view.layer?.borderWidth = 0
            }
        }
    }
    
    var contents: NSView?
    let container = NSStackView()
    
    override func loadView() {
        container.orientation = NSUserInterfaceLayoutOrientation.vertical
        container.wantsLayer = true
        
        self.view = container
    }
    
    // TODO: Double-tap to activate inspector.
    // typealias DoubleTapHandler = (_ event: NSEvent) -> Bool
    // var doubleTapHandler: DoubleTapHandler?
    // override func mouseDown(with event: NSEvent) {
    //     print(event.clickCount)
    //     if event.clickCount == 2, let handler = doubleTapHandler {
    //         if (handler(event)) {
    //             return
    //         }
    //     }
    //
    //     super.mouseDown(with: event)
    // }
}

private final class InternalCollectionView: NSCollectionView {
    // Return whether or not you handled the event
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    typealias ContextMenuItemsGenerator = (_ items: [IndexPath]) -> [NSMenuItemProxy]
    var contextMenuItemsGenerator: ContextMenuItemsGenerator? = nil
    var currentContextMenuItemProxies: [NSMenuItemProxy] = []
    
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
