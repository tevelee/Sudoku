import Foundation

final class LastPossibleSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func nextMove(on board: SudokuBoard<Value>, cache: Cache) -> Move<Value>? {
        for position in board.positionsOfRowSlices.flatMap(\.items) where board[position] == nil {
            guard let row = cache.positionsToRows[position]?.compactMap(board.value),
                  let column = cache.positionsToColumns[position]?.compactMap(board.value),
                  let region = cache.positionsToRegions[position]?.compactMap(board.value) else {
                continue
            }
            let symbols = Set(row.items + column.items + region.items)
            if symbols.count == allSymbols.count - 1, let missingValue = allSymbols.subtracting(symbols).first {
                let symbolsInRow = row.items.map(\.description).sorted().list()
                let symbolsInColumn = column.items.map(\.description).sorted().list()
                let symbolsInRegion = region.items.map(\.description).sorted().list()
                return Move(reason: "\(missingValue) is the only symbol missing at \(row.name), \(column.name)",
                            details: "\(row.name) contains \(symbolsInRow); \(column.name) contains \(symbolsInColumn); \(region.name) contains \(symbolsInRegion)",
                            value: missingValue,
                            position: position)
            }
        }
        return nil
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
