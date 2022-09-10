import Foundation
import AsyncAlgorithms

final class OneMissingSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]
    private let reservedFields: Set<ReservedFields<Value>>

    init(rules: [any SudokuRule<Value>],
         reservedFields: Set<ReservedFields<Value>> = []) {
        self.rules = rules
        self.reservedFields = reservedFields
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        let rows = moves(for: cache.rows(), on: board, cache: cache)
        let columns = moves(for: cache.columns(), on: board, cache: cache)
        let regions = moves(for: cache.regions(), on: board, cache: cache)
        return chain(rows, columns, regions).stream()
    }

    private func moves(for slices: [GridSlice], on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for slice in slices {
                if case let .oneIsMissing(values: items, emptyPosition, reservation) = analyze(slice: slice, on: board) {
                    let missingValue = Array(symbols.subtracting(items))[0]
                    let values = items.map(\.description).sorted().list()
                    let prefix = reservation.map { "Symbols \($0.values.formatted()) are \($0.name) in \($0.positions.map { formatted(position: $0, cache: cache) }.formatted()); " } ?? ""
                    let move = Move(reason: "\(prefix)\(missingValue) is the only symbol missing from \(slice.name)",
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
        let reservations = reservedFields.filter(slice.contains)
        if !reservations.isEmpty {
            for reservation in reservations {
                let values = Set(slice.items.compactMap(board.value)).union(reservation.values)
                if values.count == slice.items.count - 1,
                   let emptyPosition = Set(slice.items).subtracting(reservation.positions).first(where: { board[$0] == nil }) {
                    return .oneIsMissing(values: values, emptyPosition: emptyPosition, reservation: reservation)
                }
            }
        }
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
            return .oneIsMissing(values: values, emptyPosition: position, reservation: nil)
        } else {
            return .lessThanOneIsMissing
        }
    }

    enum SliceAnalysis {
        case oneIsMissing(values: Set<Value>, emptyPosition: Position, reservation: ReservedFields<Value>?)
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

private extension GridSlice {
    func contains<Value>(reservedFields: ReservedFields<Value>) -> Bool {
        let positions = Set(items)
        return reservedFields.positions.allSatisfy { position in
            positions.contains(position)
        }
    }
}

private func formatted<Value>(position: Position, cache: Cache<SudokuBoard<Value>>) -> String {
    let row = cache.row(for: position)?.name ?? ""
    let column = cache.column(for: position)?.name ?? ""
    return "\(row) \(column)"
}
