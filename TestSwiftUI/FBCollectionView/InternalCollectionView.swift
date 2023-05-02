import AppKit

final class InternalCollectionView: NSCollectionView {
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    var lastClickedIndexPath: IndexPath? = nil
}

public extension IndexPath {
    var intValue: Int {
        self.item
    }
}
