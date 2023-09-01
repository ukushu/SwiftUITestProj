import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @State var text: String = textSample
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text("Hello")
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                DescriptionTextField(text: $text)
                    .padding(EdgeInsets(top: 3, leading: 3, bottom: 6, trailing: 3) )
                    .background(Color.green)
            }
        }
        .frame(minWidth: 450, minHeight: 300)
    }
}

let textSample =
"""
hello 1
hello 2
hello 3
hello 4
hello 5
hello 6
hello 7
hello 8
"""
