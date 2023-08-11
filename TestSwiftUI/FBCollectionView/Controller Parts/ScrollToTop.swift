import Foundation
import Combine

extension FBCollectionView {
    func getScrollToTopCancellable() -> AnyCancellable? {
        topScroller?.sink { [self] _ in
            print("scrolling to top")
            
            DispatchQueue.main.async {
                scrollView.documentView?.scroll(.zero)
            }
        }
    }
}
