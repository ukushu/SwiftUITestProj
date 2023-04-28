//
//  NSEvent.swift
//  TestSwiftUI
//
//  Created by UKS on 28.04.2023.
//

import AppKit

public extension NSEvent {
    func modifierFlagsAreOnly(_ mustContain: NSEvent.ModifierFlags) -> Bool {
        let mustNotContain = NSEvent.ModifierFlags(arrayLiteral: .command,.control,.option,.shift).subtracting(mustContain)
        
        return self.modifierFlags.contains(mustContain) && !self.modifierFlags.contains(mustNotContain)
    }
}
