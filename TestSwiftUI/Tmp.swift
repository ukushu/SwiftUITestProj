//
//  Tmp.swift
//  TestSwiftUI
//
//  Created by UKS on 27.02.2023.
//

import Foundation

public func sleep(ms: Int ) {
    usleep(useconds_t(ms * 1000))
}

public func sleep(sec: Double ) {
    usleep(useconds_t(sec * 1_000_000))
}
