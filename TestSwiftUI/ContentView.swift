import Combine
import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @State var text: String = textSample
    @State var attrStr: NSAttributedString =  NSAttributedString(string: "")
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text("Hello")
                
                Spacer()
            }
            
            VStack {
//                AttributedText(attributedString: $attrStr)
//                    .frame(height: 300)
                
                Spacer()
                
//                TextEditor(text: $text)
//                AttrTextEditor(text: $text, font: NSFont(name: "SF Pro", size: 17)!)
//                    .frame(height: 17*6)
//                    .background(Color.green)
                DescriptionTextField(text: $text)
                    .padding(EdgeInsets(top: 3, leading: 3, bottom: 6, trailing: 3) )
                    .background(Color.green)
            }
//            .onChange(of: text) { text in
//                self.attrStr = text.asDescr()
//            }
        }
        .frame(minWidth: 450, minHeight: 300)
        .preferredColorScheme(.light)
    }
}

let textSample =
"""
hello 1
hello 2
"""


//hello 3
//hello 4
//hello 5
//hello 6
//hello 7
//hello 8










@available(OSX 11.0, *)
public struct AttributedTextOld: NSViewRepresentable {
    @Binding var text: NSAttributedString
    private let selectable: Bool
    
    public init(attributedString: Binding<NSAttributedString>, selectable: Bool = true) {
        _text = attributedString
        self.selectable = selectable
    }
    
    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField(labelWithAttributedString: text)
        textField.preferredMaxLayoutWidth = textField.frame.width
        textField.allowsEditingTextAttributes = true // Fix of clear of styles on click
        
        textField.isSelectable = selectable
        
        return textField
    }
    
    public func updateNSView(_ textField: NSTextField, context: Context) {
        textField.attributedStringValue = $text.wrappedValue
    }
}
