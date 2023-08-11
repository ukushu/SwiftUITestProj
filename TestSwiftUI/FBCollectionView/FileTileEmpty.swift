import Foundation
import SwiftUI

struct FileTileEmpty: View {
    let size: CGFloat = 126 + 7
    
    var body: some View {
        ZStack(alignment:.top) {
            Space(173, .v)
            
            RRect2()
                .padding(8)
                .frame(width: size, height: size)
            
            RRect2(4)
                .padding(4)
                .frame(width: size - 30, height: 19)
                .padding(.top, size + 5)
            
            RRect2(4)
                .padding(6)
                .frame(width: size - 50, height: 21)
                .padding(.top, size + 23)
        }
        .opacity(0.4)
    }
}

fileprivate struct RRect2: View {
    let cornerRadius: CGFloat
    
    init(_ radius: CGFloat = 7) {
        self.cornerRadius = radius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color("Filler"))
    }
}
