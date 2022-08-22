import Foundation

public protocol SudokuRule<Value> {
    associatedtype Value

    func isValid(_ slice: Slice<Value?>) -> Bool
}

extension SudokuRule {
    func isValid(_ slice: Slice<Value>) -> Bool {
        isValid(slice.map { $0 as Value? })
    }
}

public struct ContentRule<Value: Equatable>: SudokuRule {
    public let allowedSymbols: [Value]

    public func isValid(_ slice: Slice<Value?>) -> Bool {
        slice.items.allSatisfy { item in
            item.map(allowedSymbols.contains) ?? true
        }
    }
}

public struct UniqueSymbolsRule<Value: Hashable>: SudokuRule {
    public let slices: [Slice<Value>]

    public func isValid(_ slice: Slice<Value?>) -> Bool {
        var map: [Value: Int] = [:]
        for item in slice.items {
            if let item = item {
                let count = map[item] ?? 0
                if map[item] == 1 {
                    return false
                }
                map[item] = count + 1
            }
        }
        return true
    }
}
