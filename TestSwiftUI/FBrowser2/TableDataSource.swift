import Foundation
import Cocoa
import SwiftUI


public typealias CellFactory<EntityType> = (NSTableView, Int, String?, EntityType) -> NSTableCellView

open class TableDataSource<T: RandomAccessCollection>: NSObject, NSTableViewDataSource, NSTableViewDelegate where T.Index == Int {
    var items: T?
    
    // MARK: - Configuration
    public weak var tableView: NSTableView?
    public var animated = true
    public var rowAnimations = (
        insert: NSTableView.AnimationOptions.effectFade,
        update: NSTableView.AnimationOptions.effectFade,
        delete: NSTableView.AnimationOptions.effectFade)
    
    public weak var delegate: NSTableViewDelegate?
    public weak var dataSource: NSTableViewDataSource?
    
    public let cellFactory: CellFactory<T.Element>
    
    public init(cellConfigs : [String:(NSTableCellView,T.Element)->Void]) {
        cellFactory = { tableView, row, column, entity in
            guard
                let id = column,
                let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: tableView) as? NSTableCellView,
                let config = cellConfigs[id]
                else { return NSTableCellView() }
            
            config(cell,entity)
            
            return cell
        }
    }
    
    
    // MARK: - NSTableViewDataSource protocol
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return items?.count ?? 0
        //items.count
    }
    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let items = items else { return nil }
        
        let columnId = tableColumn?.identifier.rawValue
        return cellFactory(tableView, row, columnId, items[row])
    }
    
    public func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        //signals?.send(signal: Signal.Collection.Sort(descriptors: tableView.sortDescriptors))
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate ?? dataSource
    }
    
    // MARK: - Applying changeset to the table view
    private let fromRow = {(row: Int) in return IndexPath(item: row, section: 0)}
    
//    func applyChanges(items: AnyRealmCollection<EntityType>, changes: RealmChangeset?) {
//        print("apply changes \(String(describing: changes))")
//        self.items = items
//
//        guard let tableView = tableView else {
//            fatalError("You have to bind a table view to the data source.")
//        }
//
//        guard animated else {
//            tableView.reloadData()
//            return
//        }
//
//        guard let changes = changes else {
//            tableView.reloadData()
//            return
//        }
//
//        let lastItemCount = tableView.numberOfRows
//        guard items.count == lastItemCount + changes.inserted.count - changes.deleted.count else {
//            tableView.reloadData()
//            return
//        }
//
//        tableView.beginUpdates()
//        tableView.removeRows(at: IndexSet(changes.deleted), withAnimation: rowAnimations.delete)
//        tableView.insertRows(at: IndexSet(changes.inserted), withAnimation: rowAnimations.insert)
//        tableView.reloadData(forRowIndexes: IndexSet(changes.updated), columnIndexes: IndexSet(Array(0 ..< tableView.numberOfColumns)))
//        tableView.endUpdates()
//    }
}
