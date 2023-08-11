import AppKit
import AudioToolbox
import Essentials

extension InternalCollectionView {
    override func keyDown(with event: NSEvent) {
        print("keyCode = \(event.keyCode)")
        
        if let keyDownHandler = keyDownHandler {
            let didHandle = keyDownHandler(event)
            
            if (didHandle) {
                return
            }
        }
        
        
        let intVal = self.selectionIndexPaths.first?.intValue
        
//        if event.keyCode == FBKey.rightArrow,
//           self.selectionIndexPaths.count == 1,
//           let first = self.selectionIndexPaths.first,
//           (first.intValue + 1) % 8 == 0
//        {
//        }
        
        super.keyDown(with: event)
    }
}

extension FBCollectionViewConroller {
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
            
            let urls = self.selection.map{ $0 as Int }.compactMap{ items[$0] }
            
            //try to get GetInfo in single window
            // if failed - in separated windows
//            _ = AppleScript.getInfo(of: urls)
            
            return true
            
        case _ where event.keyCode == FBKey.delete && event.modifierFlags.check(equals: .command ):
            let urls = self.selection.map{ $0 as Int }.compactMap{ items[$0] }
            
            urls.forEach{ $0.FS.deleteToTrash() }
            
            //Play trash sound
            AudioServicesPlaySystemSound(0x10)
            
            return true
        case _ where event.keyCode == FBKey.esc:
            if self.selection.count > 1,
               let first = self.selection.first
            {
                self.selection = [first]
            } else {
                self.selection = []
            }
            
            return true
        default:
            return false
        }
    }
    
}


fileprivate extension FBCollectionViewConroller {
    func openFirstSelectedItemInAssociatedApp() {
        if let itemIdx = selection.sorted().first,
           let item = items[itemIdx] {
//            item.FS.openWithAssociatedApp()
        }
    }
    
    func copySelectedItems() {
        if selection.count == 1,
           let itemIdx = selection.sorted().first,
           let url = items[itemIdx]{
            Clipboard.copyFileContent(withUrl: url)
        } else if selection.count > 1 {
            let urls = selection.compactMap{ items[$0] }
            
            Clipboard.copyFilesContent(urls)
        }
    }
}
