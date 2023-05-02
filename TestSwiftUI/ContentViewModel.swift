import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let topScroller = PassthroughSubject<Void, Never>()
    
    let layout = flowLayout()
    
    @Published var filesList: [URL?] = getDirContents2()
}
