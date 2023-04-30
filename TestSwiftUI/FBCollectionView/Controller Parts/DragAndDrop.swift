import AppKit

extension FBCollectionView {
    // Just do lots of copies?
    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-modifiers-for-a-uiviewrepresentable-struct
    func onDrag(_ dragHandler: @escaping DragHandler) -> FBCollectionView {
        var view = self
        
        view.dragHandler = dragHandler
        print("view.dragHandler assigned")
        
        return view
    }
    
    func initDragAndDrop(_ collectionView: NSCollectionView) {
        // Drag and drop
        // https://www.raywenderlich.com/1047-advanced-collection-views-in-os-x-tutorial#toc-anchor-011
        if let _ = dragHandler {
            collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
        }
    }
}
