//
//  FBrowser.swift
//  TestSwiftUI
//
//  Created by UKS on 27.02.2023.
//

import Foundation
import SwiftUI

@available(OSX 11.0, *)
public struct FBrowser2<T: RandomAccessCollection, RowView: View>: NSViewControllerRepresentable where T.Index == Int {
    public typealias NSViewControllerType = NSTableController

    let id : String
    @ViewBuilder var factory: (T.Element,Int) -> RowView
    let collection : T
    let selection : Binding<Set<Int>>?
    let spec : TableSpec
    
    public init(id: String, _ collection: T, heightOfRow : CGFloat = 20, selection : Binding<Set<Int>>? = nil, @ViewBuilder factory: @escaping (T.Element, Int) -> RowView) {
        self.id = id
        self.collection = collection
        self.spec = TableSpec(heightOfRow: heightOfRow, topMargin: 0, bottomMargin: 0)
        self.factory = factory
        self.selection = selection
    }
    
    public init(id: String, _ collection: T, spec: TableSpec, selection : Binding<Set<Int>>? = nil, @ViewBuilder factory: @escaping (T.Element, Int) -> RowView) {
        self.id = id
        self.collection = collection
        self.spec = spec
        self.factory = factory
        self.selection = selection
    }
    
    public func makeNSViewController(context: Context) -> NSTableController<T, RowView> {
        let controller = NSTableController(id: id, collection: collection, spec: spec, selection: selection, factory: factory)
        let table = NSTableView()
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Column"))
        column.headerCell.title = "WTF"
        table.addTableColumn(column)
        table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        table.headerView = nil
        table.allowsMultipleSelection = spec.multiSelect
        table.style = .plain
        table.intercellSpacing = .zero
        table.selectionHighlightStyle = spec.highlightStyle;
        
        controller.tableView = table
        controller.view = scrollView(content: table)
        
        table.delegate = controller
        table.dataSource = controller
        
        if let selection = selection?.wrappedValue {
            controller.set(selection: selection)
        }
        
        if spec.firstResponder {
            // delayed calls in main thread
            DispatchQueue.main.async {
                controller.makeFirstResponder()
                
                if let selection = selection?.wrappedValue {
                    DispatchQueue.global(qos: .utility).async {
                        sleep(sec: 0.2)
                        
                        DispatchQueue.main.async {
                            controller.set(selection: selection)
                        }
                    }
                }
            }
        }
        
        return controller
    }
    


    public func updateNSViewController(_ nsViewController: NSTableController<T, RowView>, context: Context) {
        guard let tableView = nsViewController.tableView else { return }
        
        
        nsViewController.items.collection = collection
        nsViewController.items.spec = spec
        
        
        
        nsViewController.shouldNotifySelectionDidChange = false
        
        let selection = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selection, byExtendingSelection: false)
        nsViewController.shouldNotifySelectionDidChange = true
        
    }
}

fileprivate func scrollView(content: NSView) -> NSScrollView {
    let scrollView = NSScrollView(frame: .zero)
    
    scrollView.hasVerticalScroller = true
    scrollView.documentView = content
    
    return scrollView
}
