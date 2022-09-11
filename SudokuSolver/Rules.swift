import Foundation

public protocol SudokuRule<Value> {
    associatedtype Value

    func isValid(_ items: some Collection<Value?>) -> Bool
}

// TODO: check if largest side of board has equal number of elements as allowedSymbols
public struct ContentRule<Value: Hashable> {
    public let allowedSymbols: [Value]
    let symbolSet: Set<Value>

    public init(allowedSymbols: some Collection<Value>) {
        self.allowedSymbols = Array(allowedSymbols)
        self.symbolSet = Set(allowedSymbols)
        precondition(allowedSymbols.count == symbolSet.count, "Symbols should be unique")
    }
}

extension ContentRule: SudokuRule where Value: Hashable {
    public func isValid(_ items: some Collection<Value?>) -> Bool {
        items.compactMap { $0 }.allSatisfy(symbolSet.contains)
    }
}

public struct UniqueSymbolsRule<Value: Hashable> {
    public init() {}
}

private extension Array {
    func onlyCompletedValues<Wrapped>() -> [Slice<Wrapped>] where Element == BoardSlice<Wrapped?> {
        map { $0.compactMap(\.value) }
    }
}

extension UniqueSymbolsRule: SudokuRule where Value: Hashable {
    public func isValid(_ items: some Collection<Value?>) -> Bool {
        var values: Set<Value> = []
        for item in items {
            if let value = item {
                let (inserted, _) = values.insert(value)
                if !inserted {
                    return false
                }
            }
        }
        return true
    }
}
