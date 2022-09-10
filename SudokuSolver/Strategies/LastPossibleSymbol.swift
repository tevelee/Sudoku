import Foundation

final class LastPossibleSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]
    private let reservedFields: Set<ReservedFields<Value>>

    init(rules: [any SudokuRule<Value>],
         reservedFields: Set<ReservedFields<Value>> = []) {
        self.rules = rules
        self.reservedFields = reservedFields
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for position in cache.emptyPositions() {
                if let move = check(position: position, board: board, cache: cache) {
                    continuation.yield(move)
                } else {
                    for reservation in reservedFields {
                        if let move = check(position: position,
                                            board: board,
                                            cache: cache,
                                            reservation: reservation) {
                            continuation.yield(move)
                        }
                    }
                }
            }
            continuation.finish()
        }
    }

    private func check(position: Position,
                       board: SudokuBoard<Value>,
                       cache: Cache<SudokuBoard<Value>>,
                       reservation: ReservedFields<Value>? = nil) -> Move<Value>? {
        guard let row = cache.row(for: position),
              let column = cache.column(for: position),
              let region = cache.region(for: position) else {
            return nil
        }

        var symbolsInRow = Set(row.items.compactMap(board.value))
        var symbolsInColumn = Set(column.items.compactMap(board.value))
        var symbolsInRegion = Set(region.items.compactMap(board.value))

        if let reservation {
            if row.contains(reservedFields: reservation) {
                symbolsInRow.formUnion(reservation.values)
            }
            if column.contains(reservedFields: reservation) {
                symbolsInColumn.formUnion(reservation.values)
            }
            if region.contains(reservedFields: reservation) {
                symbolsInRegion.formUnion(reservation.values)
            }
        }

        let values = symbolsInRow.union(symbolsInColumn).union(symbolsInRegion)

        if values.count == allSymbols.count - 1,
           let missingValue = allSymbols.subtracting(values).first {
            let prefix = reservation.reasonPrefix(cache: cache)
            let move = Move(reason: "\(prefix)\(missingValue) is the only symbol missing at \(row.name), \(column.name)",
                            details: "\(row.name) contains \(symbolsInRow.formatted()); \(column.name) contains \(symbolsInColumn.formatted()); \(region.name) contains \(symbolsInRegion.formatted())",
                            value: missingValue,
                            position: position)
            return move
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
