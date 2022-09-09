import Foundation
import AsyncAlgorithms

final class OneMissingSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        let rows = moves(for: cache.rows(), on: board)
        let columns = moves(for: cache.columns(), on: board)
        let regions = moves(for: cache.regions(), on: board)
        return chain(rows, columns, regions).stream()
    }

    private func moves(for slices: [GridSlice], on board: SudokuBoard<Value>) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for slice in slices {
                if case let .oneIsMissing(values: items, emptyPosition) = analyze(slice: slice, on: board) {
                    let missingValue = Array(symbols.subtracting(items))[0]
                    let values = items.map(\.description).sorted().list()
                    let move = Move(reason: "\(missingValue) is the only symbol missing from \(slice.name)",
                                    details: "\(slice.name) already contains \(items.count) out of \(symbols.count) values: \(values)",
                                    value: missingValue,
                                    position: emptyPosition)
                    continuation.yield(move)
                }
            }
            continuation.finish()
        }
    }

    private func analyze(slice: GridSlice, on board: SudokuBoard<Value>) -> SliceAnalysis {
        var count = 0
        var values: Set<Value> = []
        var emptyPosition: Position?
        for position in slice.items {
            if let value = board[position] {
                values.insert(value)
            } else {
                count += 1
                emptyPosition = position
                if count > 1 {
                    return .moreThanOneIsMissing
                }
            }
        }
        if let position = emptyPosition, count == 1 {
            return .oneIsMissing(values: values, emptyPosition: position)
        } else {
            return .lessThanOneIsMissing
        }
    }

    enum SliceAnalysis {
        case oneIsMissing(values: Set<Value>, emptyPosition: Position)
        case lessThanOneIsMissing
        case moreThanOneIsMissing
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
