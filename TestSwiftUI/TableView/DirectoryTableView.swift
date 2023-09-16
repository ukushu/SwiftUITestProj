import Foundation
import Cocoa
import SwiftUI

struct DirectoryTableView: NSViewRepresentable {
    typealias NSViewType = NSScrollView
    
    @Binding var dirContent: [String]
    @Binding var selection: Set<String>
    
    func makeNSView(context: Context) -> NSScrollView {
        let tableContainer = NSScrollView(frame: .zero)
        
        tableContainer.documentView = tableViewGet(context: context)
        tableContainer.hasVerticalScroller = true
        
        return tableContainer
    }
    
    func tableViewGet(context: Context) -> NSTableView {
        let tableView = NSTableView(frame: .zero)
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        
        tableView.rowHeight = 19.0
        
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Name"))
        nameColumn.title = "Name"
        tableView.addTableColumn(nameColumn)
        
        let ageColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Size"))
        ageColumn.title = "Size"
        tableView.addTableColumn(ageColumn)
        
        let modifiedColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Modified"))
        modifiedColumn.title = "Modified"
        tableView.addTableColumn(modifiedColumn)
        
        return tableView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tableView = nsView.documentView as? NSTableView else { return }
        
        tableView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(dirContent: $dirContent, selection: $selection)
    }
}

extension DirectoryTableView {
    final class Coordinator: NSObject, NSTableViewDelegate, NSTableViewDataSource {
        @Binding var dirContent: [String]
        @Binding var selection: Set<String>
        
        init(dirContent: Binding<[String]>, selection: Binding<Set<String>>) {
            _dirContent = dirContent
            _selection = selection
        }
        
        func numberOfRows(in tableView: NSTableView) -> Int { dirContent.count }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
            switch tableColumn?.identifier.rawValue {
            case "Name":
//                var cell = NSTableCellView()
//
//                let imgView = NSImageView()
//                imgView.image = NSImage(named: "trash")
//
//                cell.subviews.append(imgView)
                
                let lbl = NSLabel()
                lbl.string = dirContent[row].asURL().lastPathComponent
//                cell.subviews.append(lbl)
                
                return lbl
                
            case "Size":
                let lbl = NSLabel()
                lbl.string = "-"
                return lbl
                
            case "Modified":
                let lbl = NSLabel()
                lbl.string = "-"
                return lbl
                
            default:
                return nil
            }
        }
        
        func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
            return true
        }
        
        func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        }
    }
}

//func label(str: String) -> NSTextView {
//    var view = NSTextView()
//    view.string = str
//    view.isEditable = false
//    view.isSelectable = false
//    view.backgroundColor = .clear
//    view.hit
//
//    return view
//}

class NSLabel: NSTextView {
    override var isEditable: Bool { get { false } set {  } }
    override var isSelectable: Bool { get { false } set { } }
    override var backgroundColor: NSColor { get { .clear } set { } }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
