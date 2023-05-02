import Quartz

extension NSCollectionController {
    var isQuickLookEnabled: Bool { quickLookHandler() != nil }
    
    var isQuickLookShowing: Bool { QLPreviewPanel.sharedPreviewPanelExists() && (QLPreviewPanel.shared()?.isVisible ?? false) }
    
    func previewItemAt(index: Int) -> QLPreviewItem? {
        guard isQuickLookEnabled else { return nil }
        
        // If no URLs, return.
        guard let urls = quickLookHandler() else { return nil }
        
        self.selection = [index-1]
        
        return urls[safe: index] as QLPreviewItem?
    }
    
    func quickLookKeyboardArrowsController(event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return false }
        
        print("Key down: \(event.keyCode); modifiders: \(event.modifierFlags)")
        
        switch event.keyCode {
        case FBKey.upArrow: fallthrough
        case FBKey.rightArrow: fallthrough
        case FBKey.downArrow: fallthrough
        case FBKey.leftArrow:
            // Don't pass through shift-selection keys
            guard event.modifierFlags.contains(.shift) == false else { return false }
            // Don't pass through command-selection keys
            guard event.modifierFlags.contains(.command) == false else { return false }
            
            // Though I believe the event is handled by QL when
            // multiple items exist, just be safe.
            //if selection.count <= 1 {
                // Forward the keydown event to the NSCollectionView, which will handle moving focus.
                collectionView?.keyDown(with: event)
                return true
//            }
        default:
            break
        }
        
        return false
    }
    
    func enableQuickLookPanel() {
        print("Space pressed & QuickLook is enabled.")
        
        guard let quickLook = QLPreviewPanel.shared() else { return }
        
        quickLook.currentPreviewItemIndex = selection.sorted(by: <).first ?? 0
        
        print("preview idx: \(quickLook.currentPreviewItemIndex)")
        
        if isQuickLookShowing {
            quickLook.reloadData()
        } else {
            quickLook.dataSource = self
            quickLook.delegate = self
            quickLook.center()
            quickLook.makeKeyAndOrderFront(nil)
        }
    }
}
