import Foundation
import AppKit
import SwiftUI

// Our custom pasteboard writer. This class also implements NSDraggingSource to handle the dragging of the item.
class FBCollectionPasteboardWriter: NSObject, NSPasteboardWriting, NSDraggingSource {
    // This function returns the types of data that this object can write to the pasteboard.
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        print("hide - writableTypes(for")
        // You need to implement this method based on the data your items can represent.
        // For example, if your items can be represented as strings, you can return [.string].
        return [.URL]
    }
    
    // This function returns a property list that represents the data of this object for a specific type.
    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        print("hide - pasteboardPropertyList(forType")
        // You need to implement this method based on the data of your item for the given type.
        // For example, if your items can be represented as strings and type is .string, you can return the string representation of your item.
        return nil
    }
    
    // This function returns the allowed operations (like .copy, .move) when the dragging is outside the source application.
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        print("hide - sourceOperationMaskFor")
        return .copy
    }
    
    func draggingSession(_ session: NSDraggingSession, willBeginAt screenPoint: NSPoint) {
        print("hide - willBeginAt")
    }
    
    // This function is called when the drag operation ends. There is no need to do anything here in this case.
    func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        print("hide - endedAt")
        // You can add any cleanup operations here after a drag operation ends
    }
    
    // This function is called when the dragging image is moved.
    // Here we check if the mouse is outside the app window, and if so, we hide the app.
    @MainActor func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        print("hide - movedTo")
        
        guard let window = NSApplication.shared.mainWindow else { return }
        
        let windowRectInScreenCoordinates = window.convertToScreen(window.frame)
        
        if !windowRectInScreenCoordinates.contains(screenPoint) {
            hideApp()
        }
    }
    
    @MainActor func ignoreModifierKeys(for session: NSDraggingSession) -> Bool { true }
}

func hideApp() {
    print("hide - appHide call")
    
    //Willeke's idea
    NSApp.windows.compactMap{$0}.forEach{
        $0.setIsVisible(false)
    }
    
    NSApplication.shared.hide(nil)
}
