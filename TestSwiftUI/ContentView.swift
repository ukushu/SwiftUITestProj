import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @State var text: String = textSample
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Hello")
            
            Spacer()
            
            MacEditorTextView(text: $text)
//            AttrTextEditor(text: $text, font: NSFont(name: "SF Pro", size: 17)! )
//                .frame( maxHeight: 17 * 5 )
//            TextField("", text: $text)
//                .padding(10)
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
