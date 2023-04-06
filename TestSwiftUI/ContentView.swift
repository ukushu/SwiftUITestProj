//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by UKS on 04.02.2023.
//

import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @ObservedObject var model = SuperViewModel()
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            FBCollectionView(items: model.filesList,
                             selection: $model.selectedItems,
                             layout: model.layout,
                             topScroller: model.topScroller.eraseToAnyPublisher()
            ) { item, indexPath in
                
                AppTile(app: item, isSelected: model.selectedItems.contains(indexPath.intValue) )
                    .id(item)
                
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
                let e = RecentFile(MDItemCreate(nil, "/Users" as CFString))!
                model.filesList.insert(e, at: 0)
                //filesList.append(RecentFile(MDItemCreate(nil, "/Users" as CFString))! )
                //filesList.sort { $0.name < $1.name }
                print("filesLst.count: \(model.filesList.count )")
            }
            
            Button("Desktop") {
                model.filesList = getDirContents1()
            }
            
            Button("Documents") {
                model.filesList = getDirContents2()
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

func getDirContents1() -> [RecentFile] {
    let girls = "/Users/uks/Desktop/BING Wallpapers".asURLdir()
    
    let url = girls.exists ? girls : URL.userHome.appendingPathComponent("Desktop")
    
    return getDirContentsFor(url: url)
        .map { $0.path }
        .compactMap { MDItemCreate(nil, $0 as CFString) }
        .compactMap { RecentFile($0) }
}

func getDirContents2() -> [RecentFile] {
    getDirContentsFor(url: URL.userHome.appendingPathComponent("Documents") )
        .map { $0.path }
        .compactMap { MDItemCreate(nil, $0 as CFString) }
        .compactMap { RecentFile($0) }
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
    
    @Published var filesList: [RecentFile] = getDirContents1().sorted { $0.name < $1.name }
}

func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 5.0, left: 20.0, bottom: 30.0, right: 15.0)
    flowLayout.minimumInteritemSpacing = 15.0
    flowLayout.minimumLineSpacing = 30.0
    
    return flowLayout
}
