import Foundation

protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible

    func moves(on board: SudokuBoard<Value>, cache: Cache) -> AsyncStream<Move<Value>>
}

extension SudokuSolvingStrategy {
    func nextMove(on board: SudokuBoard<Value>, cache: Cache) async -> Move<Value>? {
        for try await move in moves(on: board, cache: cache) {
            return move
        }
        return nil
    }

    func nextMove(on board: SudokuBoard<Value>) async -> Move<Value>? {
        await nextMove(on: board, cache: Cache(board: board))
    }
}

struct Cache {
    // TODO: use dynamic storage
    // like this https://github.com/tevelee/AsyncHTTP/blob/main/Sources/AsyncHTTP/Model/HTTPRequest.swift#L73
    var positionsToRows: [Position: GridSlice] = [:]
    var positionsToColumns: [Position: GridSlice] = [:]
    var positionsToRegions: [Position: GridSlice] = [:]

    init<Value>(board: SudokuBoard<Value>) {
        for slice in board.positionsOfRowSlices {
            for position in slice.items {
                positionsToRows[position] = slice
            }
        }
        for slice in board.positionsOfColumnSlices {
            for position in slice.items {
                positionsToColumns[position] = slice
            }
        }
        for slice in board.positionsOfRegionSlices {
            for position in slice.items {
                positionsToRegions[position] = slice
            }
        }
    }
}

public struct Move<Value> {
    let reason: String
    let details: String
    let value: Value
    let position: Position
}

extension Move: Equatable where Value: Equatable {}

extension Array where Element: CustomStringConvertible {
    func list() -> String {
        ListFormatter().string(from: self) ?? map(\.description).joined(separator: ", ")
    }
}
