//
//  ContentView.swift
//  TestSwiftUI
//
//  Created by UKS on 04.02.2023.
//

import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @State var filesLst = getDirContents(url: URL(fileURLWithPath: "/Users/uks/Desktop/DoublePen"))
    let layout = flowLayout()
    
    var body: some View {
        SwiftNSCollectionView(items: $filesLst, itemSize: nil, layout: layout) { item in
            Text(item.lastPathComponent )
        }
    }
}

func getDirContents(url: URL) -> [URL] {
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


fileprivate func flowLayout() -> NSCollectionViewFlowLayout{
    let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
            flowLayout.sectionInset = NSEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
            flowLayout.minimumInteritemSpacing = 20.0
            flowLayout.minimumLineSpacing = 20.0
            flowLayout.sectionHeadersPinToVisibleBounds = true
    return flowLayout
}
