
import Foundation
import Cocoa
import SwiftUI

@available(macOS 10.15, *)
public class TableStates : ObservableObject {
    let owner : String
    @Published public var selection : Set<Int> = []
    
    public init(id: String, owner: String) {
        self.owner = owner
        let prefix = "AppCore.Table."
        let selectionID = prefix + "Selection.\(id)"
    }
}
