import AppKit

extension NSCollectionController {
    
    func handleKeyDown(_ event: NSEvent) -> Bool {
        print("handleKeyDown: \(event.keyCode)")
        
        switch event {
        case _ where event.keyCode == FBKey.space:
            guard isQuickLookEnabled else { return false }
            enableQuickLookPanel()
            return true
        case _ where event.keyCode == FBKey.enter:
            openFirstSelectedItemInAssociatedApp()
            return true
        case _ where event.keyCode == FBKey.c:
            guard event.modifierFlags.check(equals: .command ) else { return false }
            
            copySelectedItems()
            return true
        default:
            return false
        }
    }
    
}

fileprivate extension NSCollectionController {
    func openFirstSelectedItemInAssociatedApp() {
        if let itemIdx = selection.sorted().first,
           let item = items[itemIdx] as? URL? {
            _ = FS.openWithAssociatedApp(item)
        }
    }
    
    func copySelectedItems() {
        if selection.count == 1,
           let itemIdx = selection.sorted().first,
           let url = items[itemIdx] as? URL? {
            Clipboard.copyFileContent(withUrl: url)
        } else if selection.count > 1 {
            let urls = selection.compactMap{ items[$0] as? URL? }.compactMap{ $0 }
            
            Clipboard.copyFilesContent(urls)
        }
    }
}
