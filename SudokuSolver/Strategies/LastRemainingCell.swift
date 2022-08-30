import Foundation

final class LastRemainingCellStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func nextMove(on board: SudokuBoard<Value>, cache: Cache) -> Move<Value>? {
        for region in board.positionsOfRegionSlices {
            var rowsCovered: [Position: Set<Value>] = [:]
            var columnsCovered: [Position: Set<Value>] = [:]
            for position in region.items {
                guard let row = cache.positionsToRows[position],
                      let column = cache.positionsToColumns[position] else {
                    continue
                }
                rowsCovered[position, default: []].formUnion(row.items.compactMap(board.value))
                columnsCovered[position, default: []].formUnion(column.items.compactMap(board.value))
            }

            for value in allSymbols {
                let rowsCoveredByValue = Set(rowsCovered.filter { $0.value.contains(value) }.map(\.key))
                let columnsCoveredByValue = Set(columnsCovered.filter { $0.value.contains(value) }.map(\.key))
                let positionsCoveredByValue = rowsCoveredByValue.union(columnsCoveredByValue)
                let allPositions = Set(region.items)
                if positionsCoveredByValue.count == allPositions.count - 1, let missingPosition = allPositions.subtracting(positionsCoveredByValue).first,
                   let row = cache.positionsToRows[missingPosition],
                   let column = cache.positionsToColumns[missingPosition] {
                    let rowsCovered = Set(rowsCoveredByValue.compactMap { cache.positionsToRows[$0]?.name }).sorted()
                    let columnsCovered = Set(columnsCoveredByValue.compactMap { cache.positionsToColumns[$0]?.name }).sorted()
                    let slicesCovered = (rowsCovered + columnsCovered).list()
                    return Move(reason: "Symbol \(value) covers all fields in \(region.name) except \(row.name), \(column.name)",
                                details: "In \(region.name), \(slicesCovered) contain \(value), it must be at \(row.name), \(column.name)",
                                value: value,
                                position: missingPosition)
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
