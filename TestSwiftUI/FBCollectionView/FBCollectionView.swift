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
 
 */

// TODO: ItemType extends identifiable?
// TODO: Move the delegates to a coordinator.
struct FBCollectionView<Content: View>: NSViewControllerRepresentable /* NSObject, NSCollectionViewDelegateFlowLayout */ {
    //Need to locate here for topScroller
    var scrollView: NSScrollView = NSScrollView()
    
    private let layout: NSCollectionViewFlowLayout = flowLayout()
    
    let items: [URL?]
    var selection : IndexSet { CollectionState.shared.selection }
    
    let topScroller: AnyPublisher<Void, Never>?
    
    let factory: (URL?, IndexPath) -> Content
    
    init(items: [URL?], topScroller: AnyPublisher<Void, Never>? = nil, factory: @escaping (URL?, IndexPath) -> Content) {
        self.items = items.appendEmpties()
        self.topScroller = topScroller
        self.factory = factory
    }
    
    func makeNSViewController(context: Context) -> NSViewController { createViewController() }
    
    func updateNSViewController(_ viewController: NSViewController, context: Context) { dataRefreshLogic(viewController) }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        print("updateNSView")
    }
}

//////////////////////////////
///HELPERS
/////////////////////////////
extension FBCollectionView {
    fileprivate func createViewController() -> NSViewController {
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
    
    fileprivate func dataRefreshLogic(_ viewController: NSViewController) {
        guard let scrollView = viewController.view as? NSScrollView else { return }
        guard let collectionView = scrollView.documentView as? NSCollectionView else { return }
        guard let controller = viewController as? NSCollectionController<Content> else { return }
        
        collectionView.dataSource = controller
        collectionView.delegate = controller
        
        logDataInfo()
        
        collectionView.selectionIndexes = selection
        
        logDataInfo()
        
        if controller.items == self.items {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems())
        } else {
            controller.items = self.items
            collectionView.reloadData()
        }
    }
}

extension FBCollectionView {
    private func logDataInfo() {
//        print("""
//              updateNSViewController: selInternal: \(collectionView.selectionIndexes.map{ $0 }) | selExternal: \(self.selection.map{ $0 })
//              """ )
    }
}

fileprivate func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 5.0, left: 20.0, bottom: 30.0, right: 15.0)
    flowLayout.minimumInteritemSpacing = 15.0
    flowLayout.minimumLineSpacing = 30.0
    
    return flowLayout
}


fileprivate extension Array where Element == Optional<URL> {
    func appendEmpties() -> [URL?] {
        var arr = self
        // remove all nil elements from end of array
        for i in arr.indices.reversed() {
            if arr[i] == nil {
                arr.remove(at: i)
            } else {
                break
            }
        }
        
        // fill in case of empty
        if self.count < 12 {
            let empties = (0..<(12 - self.count)).map{ _ -> URL? in nil }
            
            return arr.appending(contentsOf: empties)
        }
        
        // add needed count of empties
        let emptiesCount = arr.count % 6
        
        let empties = (0..<emptiesCount).map{ _ -> URL? in nil }
        
        return arr.appending(contentsOf: empties)
    }
}
