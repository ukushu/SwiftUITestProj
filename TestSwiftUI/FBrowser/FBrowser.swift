//
//  FBrowser.swift
//  TestSwiftUI
//
//  Created by UKS on 27.02.2023.
//

import Foundation
import SwiftUI

@available(OSX 11.0, *)
public struct FBrowser: NSViewRepresentable {
    let flowLayout: NSCollectionViewFlowLayout
    let collectionView = NSCollectionView()
    
    public init() {
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionHeadersPinToVisibleBounds = true
        self.flowLayout = flowLayout
    }
    
    public func makeNSView(context: Context) -> NSCollectionView {
        collectionView.collectionViewLayout = flowLayout
//        collectionView.layer?.backgroundColor = NSColor.black.cgColor
        collectionView.allowsMultipleSelection = true
        
        return collectionView
    }
    
    public func updateNSView(_ nsView: NSCollectionView, context: Context) {
        nsView.reloadData()
    }
    
//    public func makeCoordinator() -> Coordinator {
//        Coordinator { self.text = $0 }
//    }
}
