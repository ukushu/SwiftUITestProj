import AppKit

final class InternalCollectionView: NSCollectionView {
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    var lastClickedIndexPath: IndexPath? = nil
    
    // Do notnhing on Cmd+A
    override func selectAll(_ sender: Any?) { }
}

public extension IndexPath {
    var intValue: Int {
        self.item
    }
}
