import Foundation

final class LastPossibleSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>? {
        for position in board.positionsOfRowSlices.flatMap(\.items) where board[position] == nil {
            if let row = board.rows.first(where: { $0.items.contains(where: { $0.position == position }) }),
                let column = board.columns.first(where: { $0.items.contains(where: { $0.position == position }) }),
                let region = board.regions.first(where: { $0.items.contains(where: { $0.position == position }) }) {
                let symbols = Set(row.items.compactMap(\.value) + column.items.compactMap(\.value) + region.items.compactMap(\.value))
                if symbols.count == allSymbols.count - 1, let missingValue = allSymbols.subtracting(symbols).first {
                    let symbolsInRow = row.items.compactMap(\.value?.description).sorted().list()
                    let symbolsInColumn = column.items.compactMap(\.value?.description).sorted().list()
                    let symbolsInRegion = region.items.compactMap(\.value?.description).sorted().list()
                    return Move(reason: "\(missingValue) is the only symbol missing at \(row.name), \(column.name)",
                                details: "\(row.name) contains \(symbolsInRow); \(column.name) contains \(symbolsInColumn); \(region.name) contains \(symbolsInRegion)",
                                value: missingValue,
                                position: position)
                }
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
