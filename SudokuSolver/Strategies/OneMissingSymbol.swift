import Foundation

final class OneMissingSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>? {
        nextMove(for: board.rows) ?? nextMove(for: board.columns) ?? nextMove(for: board.regions)
    }

    private func nextMove(for slices: some Sequence<BoardSlice<Value>>) -> Move<Value>? {
        for slice in slices {
            let items = Set(slice.items.compactMap(\.value))
            if items.count == symbols.count - 1,
               let emptyPosition = slice.items.first(where: { $0.value == nil })?.position,
               let missingValue = symbols.subtracting(items).first {
                let values = slice.items.compactMap(\.value?.description).sorted().list()
                return Move(reason: "\(missingValue) is the only symbol missing from \(slice.name)",
                            details: "\(slice.name) already contains \(items.count) out of \(symbols.count) values: \(values)",
                            value: missingValue,
                            position: emptyPosition)
            }
        }
        return nil
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
