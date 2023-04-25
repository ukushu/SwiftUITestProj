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
    
    var selectedItems: IndexSet = IndexSet() {
        didSet {
//            print("model.selectedItems changed: \(selectedItems.map{ $0 } )")
            
//            self.objectWillChange.send()
        }
    }
    
    let layout = flowLayout()
    
    @Published var filesList: [URL?] = getDirContents2()
}
