import Foundation
import Cocoa
import SwiftUI
import AppKit

public struct TableSpec {
    let topMargin : CGFloat
    let bottomMargin : CGFloat
    let bottomMarginEx : CGFloat
    let heightOfRow : CGFloat
    let multiSelect : Bool
    
    let extraRows : Int
    let idxOffset : Int
    let firstResponder : Bool
    let highlightStyle: NSTableView.SelectionHighlightStyle
    
    public init(heightOfRow : CGFloat = 20, topMargin: CGFloat = 0, bottomMargin: CGFloat = 0, bottomMarginEx: CGFloat = 0, multiSelect: Bool = true, firstResponder: Bool = false, highlightStyle: NSTableView.SelectionHighlightStyle = .regular) {
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        self.bottomMarginEx = bottomMarginEx
        self.heightOfRow = heightOfRow
        self.multiSelect = multiSelect
        
        var extra = (topMargin == 0) ? 0 : 1
        extra += (bottomMargin == 0) ? 0 : 1
        self.extraRows = extra
        
        self.idxOffset = (topMargin > 0) ? 1 : 0
        self.firstResponder = firstResponder
        self.highlightStyle = highlightStyle
    }
}

fileprivate extension TableSpec {
    var shouldResizeScroll : Bool { topMargin > 0 || bottomMargin > 0}
}

@available(macOS 11.0, *)
public class NSTableController<T: RandomAccessCollection, RowView: View>: NSViewController, NSTableViewDelegate, NSTableViewDataSource where T.Index == Int {
    let         id : String
    var         factory: (T.Element, Int) -> RowView
    weak var    tableView: NSTableView?
    let         selection : Binding<Set<Int>>?

    
    var items : CollectionMapper<T>
    
    public init(id: String, collection: T, spec : TableSpec, selection : Binding<Set<Int>>?, @ViewBuilder factory: @escaping (T.Element, Int) -> RowView) {
        self.id = id
        self.items = CollectionMapper(collection: collection, spec: spec)
        self.factory = factory
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayout() {
        guard let tableView = tableView else { return }
        tableView.sizeLastColumnToFit()
        
        
        let spec = items.spec
        
        if spec.shouldResizeScroll,     let scrollView = self.view as? NSScrollView {
            if let vscroll = scrollView.verticalScroller {
                
                var origin = vscroll.frame.origin
                var size   = vscroll.frame.size
                
                origin.y += spec.topMargin
                let newHeight = size.height - (spec.topMargin + spec.bottomMargin)
                
                size.height = max(newHeight, spec.heightOfRow * 2)
                
                vscroll.frame = NSRect(origin: origin, size: size)
            }
        }
    }

    // MARK: - NSTableViewDataSource protocol
    public func numberOfRows(in tableView: NSTableView) -> Int {
        items.countTotal
    }
    
//    public func selectionShouldChange(in tableView: NSTableView) -> Bool {
//        !(selection == nil)
//    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard selection != nil else { return false }
        
        return items[row] != nil
    }
    
    var shouldNotifySelectionDidChange = true
    public func tableViewSelectionDidChange(_ notification: Notification) {
        guard shouldNotifySelectionDidChange else { return }
        
        guard let indexes = self.tableView?.selectedRowIndexes else { return }
        
        let sel = items.externalSelection(from: indexes)
        self.selection?.wrappedValue = sel
    }
    
    func set(selection indexes: Set<Int>) {
        tableView?.selectRowIndexes(items.internalSelection(from: indexes), byExtendingSelection: false)
    }

    
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        items.height(row: row)
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let targetRow = items.topSpacerIdx != nil ? row - 1: row
        
        if let item = items[row] {
            return NSHostingView(rootView: factory(item, targetRow))
        }

        return nil
    }
    
    func makeFirstResponder() {
        if tableView?.window == NSApplication.shared.mainWindow {
            NSApplication.shared.mainWindow?.makeFirstResponder(self)
        }
    }
}


struct CollectionMapper<T: RandomAccessCollection> where T.Index == Int {
    var collection : T
    var spec : TableSpec
    
    var countTotal  : Int  { collection.count + spec.extraRows }
    var topSpacerIdx    : Int? { spec.topMargin == 0 ? nil : 0 }
    var bottomSpacerIdx : Int? {
        guard spec.bottomMargin > 0 else { return nil }
        return countTotal - 1
    }
    
    public subscript(position: Int) -> T.Element? {
        guard position >= 0 else { return nil }
        
        let idx : Int
        if spec.topMargin > 0 {
            idx = position - 1
        } else {
            idx = position
        }
        
        guard idx >= 0 else { return nil }
        guard idx < collection.count else { return nil }
        
        return collection[idx]
    }
    
    func height(row: Int) -> CGFloat {
        if row == topSpacerIdx      { return spec.topMargin }
        if row == bottomSpacerIdx   { return max(spec.bottomMargin, spec.bottomMarginEx) }

        return spec.heightOfRow
    }
    
    func externalSelection(from indexes: IndexSet) -> Set<Int> {
        if spec.topMargin > 0 {
            return Set(indexes.map { $0 - 1 })
        } else {
            return Set(indexes)
        }
    }
    
    func internalSelection(from indexes: Set<Int>) -> IndexSet {
        var spacers = Set<Int>()
        if let idx = topSpacerIdx {
            spacers.insert(idx)
        }
        if let idx = bottomSpacerIdx {
            spacers.insert(idx)
        }
        
        if spec.topMargin > 0 {
            return IndexSet(indexes.filter{ ($0 < collection.count) && !spacers.contains($0) }.map { $0 + 1 })
        } else {
            return IndexSet(indexes.filter{ ($0 < collection.count) && !spacers.contains($0) })
        }
    }
}
