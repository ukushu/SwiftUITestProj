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
    let tableSpec = TableSpec(heightOfRow: 30 , multiSelect: true, highlightStyle: .regular)
    
    @State var selection: Set<Int> = []
    
    var body: some View {
        VStack{
            Text("some text")
            
            SwiftNSCollectionView(items: $filesLst, itemSize: nil) { item in
                Text(item.lastPathComponent )
            }
        }
        
//        FBrowser2(id: "RemotesList", filesLst, spec: tableSpec, selection: $selection) { file, _ in
//            Text(file.lastPathComponent)
//        }
//        .frame(width: 400, height: 400)
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
