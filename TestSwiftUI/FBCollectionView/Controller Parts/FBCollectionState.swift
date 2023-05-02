import SwiftUI

class CollectionState: ObservableObject {
    static let shared = CollectionState()
    
    private init() {}
    
    @Published var selection: IndexSet = IndexSet(integer: 0)
}
