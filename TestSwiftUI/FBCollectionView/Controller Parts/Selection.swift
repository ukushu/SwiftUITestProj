import AppKit

extension FBCollectionViewConroller {
    func shiftIsPressedItemsToAdd(_ collectionView: NSCollectionView, indexPaths: Set<IndexPath>) -> [IndexPath] {
        let new = indexPaths.sorted().last!
        let newIdx = new.item
        var old = collectionView.selectionIndexes.map{ $0 as Int }.sorted()
        
        if old.count == 0 {
            old = self.selection.sorted()
        }
        
        guard let oldLast = old.last,
              let oldFirst = old.first
        else { return [] }
        
        if oldLast < newIdx {
            let idxs = (old.last!...newIdx).map{ IndexPath(item: $0, section: 0) }
            
            return idxs
        } else if oldFirst > newIdx {
            let idxs = (newIdx...old.first!).map{ IndexPath(item: $0, section: 0) }
            
            return idxs
        }
        
        return []
    }
}
