import AppKit

final class InternalCollectionView: NSCollectionView {
    typealias KeyDownHandler = (_ event: NSEvent) -> Bool
    var keyDownHandler: KeyDownHandler? = nil
    
    var lastClickedIndexPath: IndexPath? = nil
    
    // Do notnhing on Cmd+A
    override func selectAll(_ sender: Any?) { }
}

// Page by page scroll. It does not work for some reason.
//extension InternalCollectionView {
//    override func adjustScroll(_ newVisible: NSRect) -> NSRect {
//        var modifiedRect = newVisible
//
//        modifiedRect.origin.x = ( newVisible.origin.x / 130.0 ) * 130.0
//        modifiedRect.origin.y = ( newVisible.origin.y / 130.0 ) * 130.0
//
//        return super.adjustScroll(modifiedRect)
//    }
//}

public extension IndexPath {
    var intValue: Int {
        self.item
    }
}

