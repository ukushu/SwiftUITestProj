import AppKit

final class InternalCollectionView: NSCollectionView {
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    var lastClickedIndexPath: IndexPath? = nil
    
    override func becomeFirstResponder() -> Bool {
//        becomeFirstResponder(idx: 0)
        super.becomeFirstResponder()
    }
    
    func becomeFirstResponder(idx: Int) -> Bool {
        if selectionIndexPaths.count == 0 {
            for section in 0..<numberOfSections {
                if numberOfItems(inSection: section) >= idx {
                    selectionIndexPaths = [IndexPath(item: idx, section: section)]
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
