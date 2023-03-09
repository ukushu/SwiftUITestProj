//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by UKS on 04.02.2023.
//

import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    let layout = flowLayout()
    
    @State var filesList: [RecentFile] = getDirContents1()
    @State var selectedItems: Set<Int> = []
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            FBCollectionView(items: $filesList, selectedItems: $selectedItems, layout: layout) { recent -> AnyView in
                let isSelected = selectedItems.contains( filesList.firstIndex{ $0.url == recent.url }! )
                
                return AnyView( AppTile(app: recent, isSelected: isSelected) )
            }
        }
    }
    
    @ViewBuilder
    func ButtonsPanel() -> some View {
        HStack {
            Button("delete first") {
                filesList.remove(at: 0)
                print("filesLst.count: \(filesList.count )")
            }
            
            Button("append at 0") {
                filesList.append(RecentFile(MDItemCreate(nil, "/Users" as CFString))! )
                print("filesLst.count: \(filesList.count )")
            }
            
            Button("Desktop") {
                filesList = getDirContents1()
            }
            
            Button("Documents") {
                filesList = getDirContents2()
            }
            
            Button("Select 1") {
                selectedItems = [1]
            }
            
            Button("Select 1-3") {
                selectedItems = [1,2,3]
            }
            
            Button("Select 4") {
                selectedItems = [4]
            }
        }
    }
}

func getDirContents1() -> [RecentFile] {
    getDirContentsFor(url: "/Users/".asURL() )
        .map { $0.path }
        .compactMap { MDItemCreate(nil, $0 as CFString) }
        .compactMap { RecentFile($0) }
}

func getDirContents2() -> [RecentFile] {
    getDirContentsFor(url: "/Users/Shared".asURL() )
        .map { $0.path }
        .compactMap { MDItemCreate(nil, $0 as CFString) }
        .compactMap { RecentFile($0) }
}

func getDirContentsFor(url: URL) -> [URL] {
    let fileManager = FileManager.default

    let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

    do {
        let directoryContents = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])

        return directoryContents
    } catch {
        print("Error while enumerating files \(documentsUrl.path): \(error.localizedDescription)")
    }

    return []
}


func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 5.0, left: 20.0, bottom: 30.0, right: 15.0)
    flowLayout.minimumInteritemSpacing = 15.0
    flowLayout.minimumLineSpacing = 30.0
    
    return flowLayout
}
