import Foundation
import AsyncAlgorithms

final class LastRemainingCellStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func moves(on board: SudokuBoard<Value>,
               layoutCache: inout Cache<SlicedGrid>,
               valueCache: inout Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        let regions = moves(on: board, primary: layoutCache.regions(), other1: layoutCache.positionsToRows, other2: layoutCache.positionsToColumns)
        let rows = moves(on: board, primary: layoutCache.rows(), other1: layoutCache.positionsToRegions, other2: layoutCache.positionsToColumns)
        let columns = moves(on: board, primary: layoutCache.columns(), other1: layoutCache.positionsToRows, other2: layoutCache.positionsToRegions)
        return chain(regions, rows, columns).stream()
    }

    func moves(on board: SudokuBoard<Value>,
               primary: [GridSlice],
               other1: [Position: GridSlice],
               other2: [Position: GridSlice]) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for region in primary {
                var positionsToRowValues: [Position: Set<Value>] = [:]
                var positionsToColumnValues: [Position: Set<Value>] = [:]
                for position in region.items {
                    guard let row = other1[position],
                          let column = other2[position] else {
                        continue
                    }
                    positionsToRowValues[position, default: []].formUnion(row.items.compactMap(board.value))
                    positionsToColumnValues[position, default: []].formUnion(column.items.compactMap(board.value))
                }

                let allPositions = Set(region.items)
                let regionValues = Set(region.items.compactMap(board.value))
                for value in allSymbols.subtracting(regionValues) {
                    let positionsInRowsCoveredByValue = Set(positionsToRowValues.filter { $0.value.contains(value) }.map(\.key))
                    let positionsInColumnsCoveredByValue = Set(positionsToColumnValues.filter { $0.value.contains(value) }.map(\.key))
                    let positionsCoveredByValue = positionsInRowsCoveredByValue.union(positionsInColumnsCoveredByValue)
                    if positionsCoveredByValue.count == allPositions.count - 1, let missingPosition = allPositions.subtracting(positionsCoveredByValue).first,
                       let row = other1[missingPosition],
                       let column = other2[missingPosition] {
                        let rowsCovered = Set(positionsInRowsCoveredByValue.compactMap { other1[$0]?.name }).sorted()
                        let columnsCovered = Set(positionsInColumnsCoveredByValue.compactMap { other2[$0]?.name }).sorted()
                        let slicesCovered = (rowsCovered + columnsCovered).list()
                        let move = Move(reason: "Symbol \(value) covers all fields in \(region.name) except \(row.name), \(column.name)",
                                        details: "In \(region.name), \(slicesCovered) contain \(value), it must be at \(row.name), \(column.name)",
                                        value: value,
                                        position: missingPosition)
                        continuation.yield(move)
                    }
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
