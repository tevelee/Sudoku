import Foundation
import AsyncAlgorithms

final class OneMissingSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        let rows = moves(for: cache.rows(), keyPath: \.row, covers: cache.covers())
        let columns = moves(for: cache.columns(), keyPath: \.column, covers: cache.covers())
        let regions = moves(for: cache.regions(), keyPath: \.region, covers: cache.covers())
        return chain(rows, columns, regions).stream()
    }

    private func moves(for slices: [GridSlice],
                       keyPath: KeyPath<Covers<Value>, Set<Value>>,
                       covers: [Position: CoveredValue<Value>]) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for slice in slices {
                for position in slice.items {
                    if case .incomplete(let cover) = covers[position],
                       cover[keyPath: keyPath].count == symbols.count - 1,
                       let missingValue = symbols.subtracting(cover[keyPath: keyPath]).first {
                        let items = cover[keyPath: keyPath]
                        let values = items.map(\.description).sorted().list()
                        let move = Move(reason: "\(missingValue) is the only symbol missing from \(slice.name)",
                                        details: "\(slice.name) already contains \(items.count) out of \(symbols.count) values: \(values)",
                                        value: missingValue,
                                        position: position)
                        continuation.yield(move)
                    }
                }
            }
            continuation.finish()
        }
    }

    private lazy var symbols = contentRule().map { Set($0.allowedSymbols) } ?? []

    private func contentRule() -> ContentRule<Value>? {
        for rule in rules {
            if let contentRule = isContentRule(rule) {
                return contentRule
            }
        }
        return nil
    }

    private func isContentRule(_ value: some SudokuRule<Value>) -> ContentRule<Value>? {
        value as? ContentRule<Value>
    }
}
