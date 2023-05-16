import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let topScroller = PassthroughSubject<Void, Never>()
    
    @Published var filesList: ArraySlice<URL> = getDirContents2()
}
