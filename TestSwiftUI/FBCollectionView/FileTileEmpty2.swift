//
//  FileTileEmpty2.swift
//  TestSwiftUI
//
//  Created by UKS on 23.04.2023.
//

import Foundation
import SwiftUI

struct FileTileEmpty2: View {
    let size: CGFloat = 125
    
    var body: some View {
        VStack(spacing: 5) {
            RRect2()
                .frame(width: size, height: size)
                .padding(.bottom, 5)
            
            RRect2()
                .frame(width: size - 10, height: 10)
            
            RRect2()
                .frame(width: size - 20, height: 8)
        }
    }
}

fileprivate struct RRect2: View {
//    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color("Filler"))
    }
}









struct FileTileEmpty: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            RRect()
                .frame(width: 90, height: 118)
                .frame(width: 126, height: 126)
            
            Space(6)
            
            RRect()
                .frame(width: 90, height: 15)
            
            Space(4)
            
            RRect()
                .frame(width: 126, height: 13)
        }
    }
}

fileprivate struct RRect: View {
//    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color("Filler"))
//            .foregroundColor( colorScheme == .dark ? Color(rgbaHex: 0xffffff07) : Color(rgbaHex: 0x00000007) )
    }
}
