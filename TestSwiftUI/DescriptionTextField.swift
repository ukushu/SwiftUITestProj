import Foundation
import SwiftUI
import AppKit

struct DescriptionTextField: NSViewRepresentable {
    @Binding var text: String
    
    var isEditable: Bool = true
    
    let fontSize: CGFloat = 17
    
    var onEditingChanged : () -> Void       = { }
    var onCommit         : () -> Void       = { }
    var onTextChange     : (String) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: text, isEditable: isEditable, fontSize: fontSize)
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        view.text = text
        
        view.selectedRanges = context.coordinator.selectedRanges
    }
}

extension DescriptionTextField {
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: DescriptionTextField
        var selectedRanges: [NSValue] = []
        
        init(_ parent: DescriptionTextField) {
            self.parent = parent
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged()
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.selectedRanges = textView.selectedRanges
            
            if let txtView = textView.superview?.superview?.superview as? CustomTextView {
                txtView.refreshScrollViewConstrains()
            }
        }
        
        func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            self.parent.text = textView.string
            
            self.parent.onCommit()
        }
    }
}

// MARK: - CustomTextView
final class CustomTextView: NSView {
    private var isEditable: Bool
//    private var font: NSFont?
    
    weak var delegate: NSTextViewDelegate?
    
    let fontSize: CGFloat
    
    var text: String { didSet { textView.textStorage?.setAttributedString(text.asDescr(fontSize: fontSize) )  } }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else { return }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    private lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.clear
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.isEditable              = self.isEditable
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = NSColor.labelColor
        textView.allowsUndo              = true
        textView.isRichText              = true
        
        return textView
    } ()
    
    // MARK: - Init
    init(text: String, isEditable: Bool, fontSize: CGFloat) {
        self.isEditable = isEditable
        self.text       = text
        self.fontSize   = fontSize
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Life cycle
    override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        
        scrollView.documentView = textView
    }
    
    private func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        refreshScrollViewConstrains()
    }
    
    func refreshScrollViewConstrains() {
        //17 is font size from .asDescr()
        let finalHeight = min(textView.contentSize.height, fontSize * 6)
        
        scrollView.removeConstraints(scrollView.constraints)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(lessThanOrEqualTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: finalHeight)
        ])
        
        scrollView.needsUpdateConstraints = true
    }
}

extension NSTextView {
    var contentSize: CGSize {
        get {
            guard let layoutManager = layoutManager, let textContainer = textContainer else {
                print("textView no layoutManager or textContainer")
                return .zero
            }
            
            layoutManager.ensureLayout(for: textContainer)
            return layoutManager.usedRect(for: textContainer).size
        }
    }
}

fileprivate extension String {
    func asDescr(fontSize: CGFloat) -> NSAttributedString {
        let font     = NSFont.systemFont(ofSize: fontSize)
        let fontBold = NSFont.boldSystemFont(ofSize: fontSize)
        
        let attributedText = NSMutableAttributedString(string: self)
        
        attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attributedText.length))
        
        let idx = self.indexInt(of: "\n\n")
        
        // if there exist \n\n (title and description)
        if let idx = idx {
            attributedText.addAttribute(NSAttributedString.Key.font, value: fontBold, range: NSRange(location: 0, length: idx))
            attributedText.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: idx, length: attributedText.length-idx))
        
        // if there is only commit title
        } else {
            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: font, range: NSRange(location: 0, length: attributedText.length))
        }
        
        return attributedText
    }
}
