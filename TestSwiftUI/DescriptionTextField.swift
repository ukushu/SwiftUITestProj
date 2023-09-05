import Foundation
import SwiftUI
import AppKit

struct DescriptionTextField: NSViewRepresentable {
    @Binding var text: String
    var isEditable: Bool = true
    var font: NSFont?    = .systemFont(ofSize: 17, weight: .regular)
    
    var onEditingChanged: () -> Void       = { }
    var onCommit        : () -> Void       = { }
    var onTextChange    : (String) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeNSView(context: Context) -> CustomTextView {
        let textView = CustomTextView(text: text, isEditable: isEditable, font: font)
        
        textView.delegate = context.coordinator
        
        return textView
    }
    
    func updateNSView(_ view: CustomTextView, context: Context) {
        if view.text != text {
            view.text = text
        }
        
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
    private var font: NSFont?
    
    weak var delegate: NSTextViewDelegate?
    
    var text: String { didSet { textView.string = text } }
    
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
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.clear
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.font                    = self.font
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
    init(text: String, isEditable: Bool, font: NSFont?) {
        self.font       = font
        self.isEditable = isEditable
        self.text       = text
        
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
        guard let scrollView = self.enclosingScrollView else {
            return
        }
        
        let contentHeight = self.intrinsicContentSize.height
        let finalHeight = min(contentHeight, font!.pointSize * 6)
        
        if let existingConstraint = scrollView.constraints.first(where: { $0.firstAttribute == .height }) {
            existingConstraint.isActive = false
        }
        
        let newHeightConstraint = NSLayoutConstraint(item: scrollView,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: finalHeight)
        
        newHeightConstraint.priority = .defaultHigh
        scrollView.addConstraint(newHeightConstraint)
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
