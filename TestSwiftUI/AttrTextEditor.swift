import Foundation
import AppKit
import SwiftUI
import Essentials

@available(macOS 11.0, *)
struct AttrTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont
    
    @State var attributedText: NSMutableAttributedString
    
    let controller = TFieldController()
    
    let textView: NSTextView!
    
    init(text: Binding<String>, font: NSFont) {
        self._text = text
        self.font = font
        
        attributedText = NSMutableAttributedString(string: text.wrappedValue)
        
        let textView = NSTextView()
        textView.isEditable = true
        textView.isRichText = true
        textView.isSelectable = true
        textView.font = font
        textView.delegate = controller
        
        self.textView = textView
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ view: NSScrollView, context: Context) {
        view.documentView = textView
        
        guard attributedText.string != text else { return }
        
        // clear all attributes
        attributedText.attributesClear()
        attributedText.mutableString.setString(self.text)
        attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attributedText.length))
        
        
        
        
//        let idx = text.indexInt(of: "\n\n")
//
//        // if there exist \n\n
//        if let idx = idx {
//            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location: 0, length: idx))
//            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.green, range: NSRange(location: idx, length: attributedText.length-idx))
//
//        // if there is only commit title
//        } else {
//            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location: 0, length: attributedText.length))
//        }
//
//        textView.textStorage?.setAttributedString(attributedText)
////
////        if let str = view.textStorage?.string,
////           text != str {
////            text = str
////        }
        
    }
}

class TFieldController: NSViewController, NSTextViewDelegate {
    @IBOutlet var textViewOutlet: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewOutlet.delegate = self
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        print(textView.string)
//        print("Text view changed!")
        
    }
}

extension NSMutableAttributedString {
    func attributesClear() {
        let range = NSRange(location: 0, length: self.length)
        
        self.attributes
            .keys
            .forEach {
                self.removeAttribute($0, range: range)
            }
    }
}

public extension String {
    func indexInt(of str: any StringProtocol) -> Int? {
        return index(of: str)?.utf16Offset(in: self)
    }
}
