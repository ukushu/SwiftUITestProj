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
    
    @Published var selectedItems: IndexSet = IndexSet()
    
    let layout = flowLayout()
    
    @Published var filesList: [URL?] = getDirContents2()
}
