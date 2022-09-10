import Foundation

public protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>>
}

extension SudokuSolvingStrategy {
    func nextMove(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) async -> Move<Value>? {
        await moves(on: board, cache: cache).first
    }
}

public extension SudokuSolvingStrategy {
    func moves(on board: SudokuBoard<Value>) -> AsyncStream<Move<Value>> {
        moves(on: board, cache: Cache(board))
    }

    func nextMove(on board: SudokuBoard<Value>) async -> Move<Value>? {
        await nextMove(on: board, cache: Cache(board))
    }

    func distinctMoves(on board: SudokuBoard<Value>) async -> Set<Move<Value>> where Value: Hashable {
        let allMoves = await Array(moves(on: board))
        var movesAtPositions: [Position: Set<Move<Value>>] = [:]
        for move in allMoves {
            movesAtPositions[move.position, default: []].insert(move)
        }
        return Set(movesAtPositions.values.compactMap { moves -> Move<Value>? in
            guard var move = moves.first else { return nil }
            move.reasons = moves.reduce(into: []) { $0.formUnion($1.reasons) }
            return move
        })
    }
}

public struct Field<T> {
    let position: Position
    let value: T
}

extension Field: Equatable where T: Equatable {}
extension Field: Hashable where T: Hashable {}

enum CoveredValue<Value: Hashable> {
    case done(Value)
    case incomplete(Covers<Value>)
}

extension CoveredValue: Equatable where Value: Equatable {}
extension CoveredValue: Hashable where Value: Hashable {}

struct Covers<Value: Hashable>: Hashable {
    let row: Set<Value>
    let column: Set<Value>
    let region: Set<Value>

    var all: Set<Value> { row.union(column).union(region) }
}

public struct Move<Value> {
    let value: Value
    let position: Position
    var reasons: Set<Reason>

    struct Reason: Hashable {
        let level1: String
        let level2: String
    }

    init(value: Value, position: Position, reasons: Set<Reason>) {
        self.value = value
        self.position = position
        self.reasons = reasons
    }

    init(reason: String, details: String, value: Value, position: Position) {
        self.value = value
        self.position = position
        self.reasons = [Reason(level1: reason, level2: details)]
    }
}

extension Move: Equatable where Value: Equatable {}
extension Move: Hashable where Value: Hashable {}

extension AsyncSequence {
    var first: Element? {
        get async {
            do {
                for try await item in self {
                    return item
                }
            } catch {}
            return nil
        }
    }
}
