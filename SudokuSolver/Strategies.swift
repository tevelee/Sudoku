import Foundation

protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible
    func nextMove(on board: SudokuBoard<Value>, cache: Cache) -> Move<Value>?
}

extension SudokuSolvingStrategy {
    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>? {
        nextMove(on: board, cache: Cache(board: board))
    }
}

struct Cache {
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
