import Foundation
import SwiftUI

struct FileTileEmpty: View {
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
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color("Filler"))
    }
}
