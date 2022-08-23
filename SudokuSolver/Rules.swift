import Foundation

public protocol SudokuRule<Value> {
    associatedtype Value

    func isValid(_ slice: Slice<Value?>) -> Bool
}

// TODO: check if largest side of board has equal number of elements as allowedSymbols
public struct ContentRule<Value> {
    public let allowedSymbols: [Value]

    public init(allowedSymbols: some Collection<Value>) {
        self.allowedSymbols = Array(allowedSymbols)
    }
}

extension ContentRule: SudokuRule where Value: Equatable {
    public func isValid(_ slice: Slice<Value?>) -> Bool {
        slice.items.allSatisfy { item in
            item.map(allowedSymbols.contains) ?? true
        }
    }
}

public struct UniqueSymbolsRule<Value> {
    public let slices: [Slice<Value>]

    public init(slices: [Slice<Value>]) {
        self.slices = slices
    }

    public init(rowsAndColumnsAndRegions board: SudokuBoard<Value>) {
        self.init(slices: [
            Array(board.rows.onlyCompletedValues()),
            Array(board.columns.onlyCompletedValues()),
            Array(board.regions.onlyCompletedValues())
      ].flatMap { $0 })
    }
}

private extension Sequence {
    func onlyCompletedValues<Wrapped>() -> some Sequence<Slice<Wrapped>> where Element == Slice<Wrapped?> {
        map { $0.compactMap { $0 } }
    }
}

extension UniqueSymbolsRule: SudokuRule where Value: Hashable {
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
