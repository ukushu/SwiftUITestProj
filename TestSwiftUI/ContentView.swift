import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @ObservedObject var model = ContentViewModel()
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            Text("Selected: \(CollectionState.shared.selection.map{ "\($0)" }.joined(separator: ", ") )")
            
            FBCollectionView(items: model.filesList,
                             layout: model.layout,
                             topScroller: model.topScroller.eraseToAnyPublisher()
            ) { url, indexPath in
                FileItem(url: url, indexPath: indexPath)
            }
        }
    }
}

////////////////////////////////
///HELPERS
////////////////////////////////

extension ContentView {
    @ViewBuilder
    func FileItem(url: URL?, indexPath: IndexPath) -> some View {
        if let url = url {
            FileTile(url: url, indexPath: indexPath)
        } else {
            FileTileEmpty()
        }
    }
    
    @ViewBuilder
    func ButtonsPanel() -> some View {
        HStack {
            Button("delete first") {
                if !model.filesList.isEmpty {
                    model.filesList.remove(at: 0)
                }
                print("filesLst.count: \(model.filesList.count )")
            }
            
            Button("append at 0") {
                model.filesList.insert("/Users".asURLdir(), at: 0)
                
                print("filesLst.count: \(model.filesList.count )")
            }
            
            Button("Desktop") {
                model.filesList = getDirContents1()
            }
            
            Button("Documents") {
                model.filesList = getDirContents2()
            }
            
            if URL.userHome.appendingPathComponent("/Desktop/Test").exists {
                Button("Test") {
                    model.filesList = getDirContents3()
                }
            }
            
            Button("Empty") {
                model.filesList = [].appendEmpties()
            }
            
            Button("Select 1") {
                CollectionState.shared.selection = [1]
            }
            
            Button("Select 1-3") {
                CollectionState.shared.selection = [1,2,3]
            }
            
            Button("Select 4") {
                CollectionState.shared.selection = [4]
            }
            
            Button("Scroll to top") {
                model.topScroller.send()
            }
        }
    }
}
