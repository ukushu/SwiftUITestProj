import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @ObservedObject var model = SuperViewModel()
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            Text("Selected: \(model.selectedItems.map{ "\($0)" }.joined(separator: ", ") )")
            
            FBCollectionView(items: model.filesList,
                             selection: $model.selectedItems,
                             layout: model.layout,
                             topScroller: model.topScroller.eraseToAnyPublisher()
            ) { item, indexPath in
                AppTile(url: item, isSelected: model.selectedItems.contains(indexPath.intValue) )
            }
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

func getDirContents1() -> [URL] {
    let wallpapers = URL.userHome.appendingPathComponent("/Desktop/Wallpapers")
    
    let url = wallpapers.exists ? wallpapers : URL.userHome.appendingPathComponent("Desktop")
    
    return getDirContentsFor(url: url).sorted { $0 < $1 }
}

func getDirContents2() -> [URL] {
    getDirContentsFor(url: URL.userHome.appendingPathComponent("Downloads") ).sorted { $0 < $1 }
}

func getDirContents3() -> [URL] {
    getDirContentsFor(url: URL.userHome.appendingPathComponent("/Desktop/Test") ).sorted { $0 < $1 }
}

func getDirContentsFor(url: URL) -> [URL] {
    let fileManager = FileManager.default
    
    do {
        let directoryContents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
        
        return directoryContents
    } catch {
        print("Error while enumerating files \(url.path): \(error.localizedDescription)")
    }
    
    return []
}

class SuperViewModel: ObservableObject {
    let topScroller = PassthroughSubject<Void, Never>()
    
    @Published var selectedItems: Set<Int> = []
    
    let layout = flowLayout()
    
    @Published var filesList: [URL] = getDirContents1()
}

func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 5.0, left: 20.0, bottom: 30.0, right: 15.0)
    flowLayout.minimumInteritemSpacing = 15.0
    flowLayout.minimumLineSpacing = 30.0
    
    return flowLayout
}

extension URL : Comparable {
    public static func < (lhs: URL, rhs: URL) -> Bool {
        lhs.path < rhs.path
    }
}
