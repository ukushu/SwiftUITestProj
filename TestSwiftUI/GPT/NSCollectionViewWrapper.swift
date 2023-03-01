import SwiftUI
import AppKit

struct NSCollectionViewWrapper: NSViewRepresentable {
    var dataSource: NSCollectionViewDataSource
    var selectedItems: Binding<Set<Int>>
    
    func makeNSView(context: Context) -> NSCollectionView {
        let collectionView = NSCollectionView()
        collectionView.collectionViewLayout = flowLayout()
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.dataSource = dataSource
        collectionView.delegate = context.coordinator
        
        collectionView.register(MyItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("MyItem"))
        
        return collectionView
    }
    
    func updateNSView(_ nsView: NSCollectionView, context: Context) {
        nsView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedItems: selectedItems)
    }
}

extension NSCollectionViewWrapper {
    class Coordinator: NSObject, NSCollectionViewDelegate {
        var selectedItems: Binding<Set<Int>>
        
        init(selectedItems: Binding<Set<Int>>) {
            self.selectedItems = selectedItems
        }
        
        func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
            var selection = Set<Int>()
            
            for indexPath in indexPaths {
                selection.insert(indexPath.item)
            }
            
            selectedItems.wrappedValue = selection
        }
        
        func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
            var selection = Set<Int>()
            
            for indexPath in collectionView.selectionIndexPaths {
                selection.insert(indexPath.item)
            }
            
            selectedItems.wrappedValue = selection
        }
    }
}

class MyDataSource: NSObject, NSCollectionViewDataSource {
    var items: [String] = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("MyItem"), for: indexPath) as! MyItem
        item.textField?.stringValue = items[indexPath.item]
        return item
    }
}

class MyItem: NSCollectionViewItem {
    override func loadView() {
        self.view = NSView()
        let textField = NSTextField()
        textField.isEditable = false
        textField.isSelectable = false
        textField.backgroundColor = NSColor.clear
        textField.drawsBackground = false
        textField.isBezeled = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            textField.topAnchor.constraint(equalTo: self.view.topAnchor),
            textField.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.textField = textField
    }
}
