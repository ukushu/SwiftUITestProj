import SwiftUI
import AsyncNinja
import Essentials

class CollectionState: NinjaContext.Main, ObservableObject {
    static let shared = CollectionState()
    
    var timerCall: TimerCall! = nil
    
    @Published private(set) var selection: IndexSet = IndexSet(integer: 0) 
    
    func resetSelection() {
        DispatchQueue.main.sync {
            selection = IndexSet(integer: 0)
        }
    }
    
    var selectionOlder: [IndexSet] = []
    
    private override init() {
        super.init()
        
        selectionOlder = [selection]
        
        emptySelectionAutofix()
    }
    
    var updateSelection : ((IndexSet)->())?
    
    func addSelection(idx: Int) {
        var new = selection
        new.insert(idx)
        updateSelection?(new)
        self.selection = new
    }
    
    func setSelection(_ indexSet: IndexSet) {
        if selection != indexSet {
            selection = indexSet
        }
    }
    
    func setSelectionIfNotContains(_ idx: Int) {
        if !selection.contains(idx) {
            selection = IndexSet(integer: idx)
        }
    }
    
    func removeSelection(idx: Int) {
        var new = selection
        new.remove(idx)
        updateSelection?(new)
        self.selection = new
    }
    
    func clearSelection() {
        updateSelection?([])
        self.selection = []
    }
}

extension CollectionState {
    func emptySelectionAutofix() {
        self.timerCall = TimerCall(.continious(interval: 0.05) ) { [weak self] in
            guard let me = self else { return }
            
            me.selectionOlder.append(me.selection)
            
            if me.selectionOlder.count > 3 {
                me.selectionOlder.remove(at: 0)
            }
            
            let last = me.selection
            guard let beforeLast = me.selectionOlder.dropLast().last,
                  let oldest = me.selectionOlder.first
            else { return }
            
            if last.count == 0 && beforeLast.count == 0 {
                if let ha = oldest.map({ $0 }).sorted().first {
                    me.selection = IndexSet(integer: ha)
                }
            }
        }
    }
}
