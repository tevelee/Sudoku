import Foundation

final class LastPossibleSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for (position, cover) in cache.covers() {
                if case let .incomplete(covers) = cover,
                   covers.all.count == allSymbols.count - 1,
                   let missingValue = allSymbols.subtracting(covers.all).first,
                   let row = cache.row(for: position)?.compactMap(board.value),
                   let column = cache.column(for: position)?.compactMap(board.value),
                   let region = cache.region(for: position)?.compactMap(board.value) {
                    let symbolsInRow = row.items.map(\.description).sorted().list()
                    let symbolsInColumn = column.items.map(\.description).sorted().list()
                    let symbolsInRegion = region.items.map(\.description).sorted().list()
                    let move = Move(reason: "\(missingValue) is the only symbol missing at \(row.name), \(column.name)",
                                    details: "\(row.name) contains \(symbolsInRow); \(column.name) contains \(symbolsInColumn); \(region.name) contains \(symbolsInRegion)",
                                    value: missingValue,
                                    position: position)
                    continuation.yield(move)
                }
            }
            continuation.finish()
        }
    }

    private lazy var allSymbols = contentRule().map { Set($0.allowedSymbols) } ?? []

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
