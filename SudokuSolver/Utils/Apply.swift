import Foundation

protocol Apply {}
extension Apply {
    func apply(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}
extension NSObject: Apply {}
