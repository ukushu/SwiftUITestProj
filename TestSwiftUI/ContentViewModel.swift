//
//  ContentViewModel.swift
//  TestSwiftUI
//
//  Created by UKS on 25.04.2023.
//

import Foundation
import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let topScroller = PassthroughSubject<Void, Never>()
    
    let layout = flowLayout()
    
    @Published var filesList: [URL?] = getDirContents2()
}

class CollectionState: ObservableObject {
    static let shared = CollectionState()
    
    private init() {}
    
    @Published var selection: IndexSet = IndexSet()
}
