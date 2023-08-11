import AppKit

/*
 To support drag-and-drop, you'll need to implement the relevant NSCollectionViewDelegate methods, but you have to register the kind of drag-and-drop operations SlidesPro supports.
 
 https://www.kodeco.com/1047-advanced-collection-views-in-os-x-tutorial#toc-anchor-011
 */

extension FBCollectionView {
    func initDragAndDrop(_ collectionView: NSCollectionView) {
        // Enabled dragging items from the collection view to other applications
        // https://www.kodeco.com/1047-advanced-collection-views-in-os-x-tutorial#toc-anchor-011
        collectionView.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
    }
}

extension FBCollectionViewConroller {
    func preventHidingDuringDrag(_ collectionView: NSCollectionView) {
        let indexPaths = collectionView.indexPathsForVisibleItems()
        
        indexPaths.forEach{
            collectionView.item(at: $0.item )?.view.isHidden = false
        }
    }
}
