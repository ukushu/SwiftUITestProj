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
    var scrollView = NSScrollView()
    let topScroller: AnyPublisher<Void, Never>?
    
    private let layout: NSCollectionViewFlowLayout = flowLayout()
    
    private let factory: (URL?, IndexPath) -> Content
    
    let items: [URL?]
    var selection : IndexSet { CollectionState.shared.selection }
    
    init(items: ArraySlice<URL>, topScroller: AnyPublisher<Void, Never>? = nil, factory: @escaping (URL?, IndexPath) -> Content) {
        self.items = items.map{ $0 as URL? }.appendEmpties()
        self.topScroller = topScroller
        self.factory = factory
    }
    
    func makeNSViewController(context: Context) -> NSViewController { createViewController() }
    
    func updateNSViewController(_ viewController: NSViewController, context: Context) { dataRefreshLogic(viewController) }
}

//////////////////////////////
///HELPERS
/////////////////////////////
extension FBCollectionView {
    fileprivate func createViewController() -> NSViewController {
        let collectionView = InternalCollectionView()
        
        let viewController = NSCollectionController(collection: self.items,
                                                    factory: factory,
                                                    collectionView: collectionView,
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
            controller.items = self.items.appendEmpties()
            collectionView.reloadData()
        }
    }
}

extension FBCollectionView {
    private func logDataInfo() {
//        Log.print("""
//              updateNSViewController: selInternal: \(collectionView.selectionIndexes.map{ $0 }) | selExternal: \(self.selection.map{ $0 })
//              """ )
    }
}

fileprivate func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 15.0, left: 20.0, bottom: 26.0, right: 20.0)
    flowLayout.minimumInteritemSpacing = 1.0
    flowLayout.minimumLineSpacing = 22.0
    
    return flowLayout
}


fileprivate extension Array where Element == Optional<URL> {
    func appendEmpties() -> [URL?] {
        let itemsInRow = 8 // or 16
        
        let arr: [URL?] = self
        
        // fill in case of empty
        if self.count == 0 && arr.count % itemsInRow == 0 {
            let empties = (1...itemsInRow).map{ _ -> URL? in nil }
            return arr.appending(contentsOf: empties)
        }
        
        // DELETE ME????
        //remove all nil elements from end of array
//        for i in arr.indices.reversed() {
//            if arr[i] == nil {
//                arr.remove(at: i)
//            } else {
//                break
//            }
//        }
        
        // need to add N nil elements
        if self.count > 0 && self.count % itemsInRow > 0 {
            let emptiesCount = itemsInRow - arr.count % itemsInRow
            
            let empties = (0..<emptiesCount).map{ _ -> URL? in nil }
            
            return arr.appending(contentsOf: empties)
        }
        
        return arr
    }
}
