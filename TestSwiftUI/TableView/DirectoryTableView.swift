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
        
        func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
            switch tableColumn?.identifier.rawValue {
            case "Name":
                return dirContent[row].asURL().lastPathComponent
            case "Size":
                return "-"
            case "Modified":
                return "-"
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
