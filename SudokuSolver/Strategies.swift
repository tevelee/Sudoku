import Foundation

public protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible

    func moves(on board: SudokuBoard<Value>, cache: inout Cache<Value>) -> AsyncStream<Move<Value>>
}

public extension SudokuSolvingStrategy {
    func nextMove(on board: SudokuBoard<Value>, cache: inout Cache<Value>) async -> Move<Value>? {
        await moves(on: board, cache: &cache).first
    }

    func nextMove(on board: SudokuBoard<Value>) async -> Move<Value>? {
        var cache = Cache(board: board)
        return await nextMove(on: board, cache: &cache)
    }
}

public protocol SudokuBoardCache {
    associatedtype Value: Hashable

    static func compute<T>(_ board: SudokuBoard<T>) -> Value
}

public extension Cache {
    var positionsToRows: [Position: GridSlice] {
        mutating get {
            self[PositionsInRowsCache.self]
        }
    }
    var positionsToColumns: [Position: GridSlice] {
        mutating get {
            self[PositionsInColumnsCache.self]
        }
    }
    var positionsToRegions: [Position: GridSlice] {
        mutating get {
            self[PositionsInRegionsCache.self]
        }
    }
}

struct PositionsInRowsCache: SudokuBoardCache {
    typealias Value = [Position: GridSlice]

    static func compute<T>(_ board: SudokuBoard<T>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in board.positionsOfRowSlices {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

struct PositionsInColumnsCache: SudokuBoardCache {
    typealias Value = [Position: GridSlice]

    static func compute<T>(_ board: SudokuBoard<T>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in board.positionsOfColumnSlices {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

struct PositionsInRegionsCache: SudokuBoardCache {
    typealias Value = [Position: GridSlice]

    static func compute<T>(_ board: SudokuBoard<T>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in board.positionsOfRegionSlices {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

public struct Cache<Value> {
    private let board: SudokuBoard<Value>
    private var objects: [ObjectIdentifier: AnyHashable] = [:]

    subscript<O: SudokuBoardCache>(object: O.Type) -> O.Value {
        mutating get {
            let id = ObjectIdentifier(object)
            if let value = objects[id]?.base as? O.Value {
                return value
            }
            let value = O.compute(board)
            objects[id] = AnyHashable(value)
            return value
        }
    }

    init(board: SudokuBoard<Value>) {
        self.board = board
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
