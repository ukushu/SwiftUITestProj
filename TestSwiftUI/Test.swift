//
//  Test.swift
//  TestSwiftUI
//
//  Created by UKS on 01.04.2023.
//

import Foundation
import SwiftUI

import SwiftUI

struct Draggable: ViewModifier {
    @State private var dragOffset = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation
                        let window = NSApplication.shared.windows.first
                        window?.setFrameOrigin(NSPoint(x: window?.frame.origin.x ?? 0 + value.translation.width, y: window?.frame.origin.y ?? 0 - value.translation.height))
                    }
                    .onEnded { _ in
                        self.dragOffset = CGSize.zero
                    }
            )
    }
}

extension View {
    func draggable() -> some View {
        self.modifier(Draggable())
    }
}
