import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @ObservedObject var model = ContentViewModel()
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            Text("Selected: \(model.selectedItems.map{ "\($0)" }.joined(separator: ", ") )")
            
            FBCollectionView(items: model.filesList,
                             selection: $model.selectedItems,
                             layout: model.layout,
                             topScroller: model.topScroller.eraseToAnyPublisher()
            ) { url, indexPath in
//                Text(item.lastPathComponent)
                
                FileItem(url: url, selected: model.selectedItems.contains(indexPath.intValue))
            }
        }
    }
    
    @ViewBuilder
    func FileItem(url: URL?, selected: Bool) -> some View {
        if let url = url {
            FileTile(url: url, isSelected: selected)
        } else {
            FileTileEmpty2()
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
                model.selectedItems = [1]
            }
            
            Button("Select 1-3") {
                model.selectedItems = [1,2,3]
            }
            
            Button("Select 4") {
                model.selectedItems = [4]
            }
            
            Button("Scroll to top") {
                model.topScroller.send()
            }
        }
    }
}

