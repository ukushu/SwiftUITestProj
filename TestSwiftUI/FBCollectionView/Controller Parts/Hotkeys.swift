import AppKit
import AudioToolbox

extension InternalCollectionView {
    override func keyDown(with event: NSEvent) {
        if let keyDownHandler = keyDownHandler {
            let didHandle = keyDownHandler(event)
            
            if (didHandle) {
                return
            }
        }
        
        super.keyDown(with: event)
    }
}

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
        case _ where event.keyCode == FBKey.c && event.modifierFlags.check(equals: .command ):
            
            copySelectedItems()
            return true
        case _ where event.keyCode == FBKey.i && event.modifierFlags.check(equals: .command ):
//            guard  else { return false }
            
            let urls = self.selection.map{ $0 as Int }.compactMap{ items[$0] as? URL? }.compactMap{ $0 }
            
            FS.openGetInfoWnd(for: urls)
            
            return true
            
        case _ where event.keyCode == FBKey.delete && event.modifierFlags.check(equals: .command ):
            let urls = self.selection.map{ $0 as Int }.compactMap{ items[$0] as? URL? }.compactMap{ $0 }
            
            urls.forEach{ $0.FS.deleteToTrash() }
            
            //Play trash sound
            AudioServicesPlaySystemSound(0x10)
            
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
