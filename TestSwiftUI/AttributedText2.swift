////
////  AttributedText.swift
////  AppCore
////
////  Created by Loki on 28.02.2020.
////  Copyright © 2020 Loki. All rights reserved.
////
//
//import SwiftUI
//import Cocoa
//import Essentials
//
//@available(OSX 11.0, *)
//public struct AttributedText2: View {
//    @Binding var text: NSTextStorage?
//    
//    public init(textStorage: Binding<NSTextStorage?>) {
//        _text = textStorage
//    }
//    
//    public var body: some View {
//        AttributedTextInternal2(text: _text)
//            //.frame(minWidth: $text.wrappedValue.size().width + 350, minHeight: $text.wrappedValue.size().height )
//    }
//}
//
//@available(OSX 11.0, *)
//public struct AttributedText: View {
//    @Binding var text: NSAttributedString
//    
//    public init(attributedString: Binding<NSAttributedString>) {
//        _text = attributedString
//    }
//    
//    public var body: some View {
//        AttributedTextInternal(attributedString: $text)
//            .frame(minWidth: $text.wrappedValue.size().width + 350, minHeight: $text.wrappedValue.size().height )
//    }
//}
//
//@available(OSX 11.0, *)
//public struct AttributedTextInternal: NSViewRepresentable {
//    @Binding var text: NSAttributedString
//    
//    public init(attributedString: Binding<NSAttributedString>) {
//        _text = attributedString
//    }
//    
//    public func makeNSView(context: Context) -> NSTextView {
//        let textView = NSTextView()
//        textView.isEditable = false
//        textView.isRichText = true
//        textView.isSelectable = true
//        
//        textView.textStorage?.setAttributedString(text)
//        return textView
//    }
//    
//    public func updateNSView(_ textView: NSTextView, context: Context) {
//        textView.textStorage?.setAttributedString(text)
//    }
//}
//
//@available(OSX 11.0, *)
//public struct AttributedTextInternal2: NSViewRepresentable {
//    @Binding var text: NSTextStorage?
//    
//    public init(text: Binding<NSTextStorage?>) {
//        self._text = text
//    }
//    
//    public func makeNSView(context: Context) -> NSTextView {
//        let textView = NSTextView()
//        textView.isRichText = true
//        textView.isSelectable = true
//        self.text = textView.textStorage
//
//        return textView
//    }
//    
//    public func updateNSView(_ textView: NSTextView, context: Context) {
//        //textView.tex
//        //textView.textStorage?.setAttributedString(text)
//    }
//}
//
//// https://github.com/kyle-n/HighlightedTextEditor/blob/main/Sources/HighlightedTextEditor/HighlightedTextEditor.AppKit.swift
