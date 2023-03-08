//
//  SpacerExt.swift
//  AppCore
//
//  Created by UKS on 28.05.2021.
//  Copyright © 2021 Loki. All rights reserved.
//

import SwiftUI

public enum SpaceDirection{
    case h
    case v
    case both
}

@available(OSX 11.0, *)
public struct Space : View {
    private let exact: CGFloat?
    private let min: CGFloat?
    private let max: CGFloat?
    private let direction: SpaceDirection
    
    public init() {
        self.exact = nil
        self.min = nil
        self.max = nil
        self.direction = .both
    }
    
    public init (_ exact: CGFloat? = nil, _ direction: SpaceDirection = .both) {
        self.exact = exact
        self.min = nil
        self.max = nil
        self.direction = direction
    }
    
    public init (min: CGFloat? = nil, max: CGFloat? = nil, _ direction: SpaceDirection = .both) {
        self.exact = nil
        self.min = min
        self.max = max
        self.direction = direction
    }
    
    @ViewBuilder
    public var body: some View {
        if let exact = exact {
            Spacer( minLength: 0 )
                .frame(width: (direction == .both || direction == .h) ? exact : 0,
                       height: (direction == .both || direction == .v) ? exact : 0
                )
        } else {
            switch direction {
            case .both:
                if max == nil {
                    Spacer( minLength: min ?? 0 )
                } else {
                    Spacer( minLength: min ?? 0 )
                        .frame(maxWidth: max, maxHeight: max)
                }
            case .h:
                if max == nil {
                    Spacer( minLength: min ?? 0 )
                } else {
                    Spacer( minLength: min ?? 0 )
                        .frame(maxWidth: max)
                }
            case .v:
                if max == nil {
                    Spacer( minLength: min ?? 0 )
                } else {
                    Spacer( minLength: min ?? 0 )
                        .frame(maxHeight: max)
                }
            }
        }
    }
}
