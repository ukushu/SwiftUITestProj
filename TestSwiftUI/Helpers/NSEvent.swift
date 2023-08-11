import AppKit

extension NSEvent.ModifierFlags {
    func check(equals: NSEvent.ModifierFlags) -> Bool { check(equals: [equals]) }
    
    func check(equals: [NSEvent.ModifierFlags] ) -> Bool {
        var notEquals: [NSEvent.ModifierFlags] = [.shift, .command, .control, .option]
        
        equals.forEach{ val in notEquals.removeFirst(where: { $0 == val }) }
        
        var result = true
        
        equals.forEach{ val in
            if result {
                result = self.contains(val)
            }
        }
        
        notEquals.forEach{ val in
            if result {
                result = !self.contains(val)
            }
        }
        
        return result
    }
    
    func check(oneOf flags: [NSEvent.ModifierFlags] ) -> Bool {
        for flag in flags {
            if check(equals: flag) {
                return true
            }
        }
        
        return false
    }
}
