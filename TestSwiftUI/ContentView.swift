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
    
    @State var filesList: [RecentFile] = getDirContents1().sorted { $0.name < $1.name }
    @State var selectedItems: Set<Int> = []
    
    var body: some View {
        VStack {
            ButtonsPanel()
            
            
            Image(systemName: "homekit")
            FBCollectionView(items: filesList, selection: selectedItems, layout: layout) { item, indexPath in
//                Image(systemName: "homekit")
                //VStack {
                VStack {
                    Text(item.name)
                    Image(nsImage: item.url.path.FS.info.hiresIcon(size: 30))
                    
                }.frame(width: 50, height: 50)
            }
        }
    }
    
    @ViewBuilder
    func ButtonsPanel() -> some View {
        HStack {
            Button("delete first") {
                if !filesList.isEmpty {
                    filesList.remove(at: 0)
                }
                print("filesLst.count: \(filesList.count )")
            }
            
            Button("append at 0") {
                let e = RecentFile(MDItemCreate(nil, "/Users" as CFString))!
                filesList.insert(e, at: 0)
                //filesList.append(RecentFile(MDItemCreate(nil, "/Users" as CFString))! )
                //filesList.sort { $0.name < $1.name }
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
    getDirContentsFor(url: "/Users/uks/Desktop".asURL() )
        .map { $0.path }
        .compactMap { MDItemCreate(nil, $0 as CFString) }
        .compactMap { RecentFile($0) }
}

func getDirContents2() -> [RecentFile] {
    getDirContentsFor(url: "/Users/uks/Documents".asURL() )
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


func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
    
    flowLayout.itemSize = NSSize(width: 130.0, height: 173.0)
    flowLayout.sectionInset = NSEdgeInsets(top: 5.0, left: 20.0, bottom: 30.0, right: 15.0)
    flowLayout.minimumInteritemSpacing = 15.0
    flowLayout.minimumLineSpacing = 30.0
    
    return flowLayout
}
