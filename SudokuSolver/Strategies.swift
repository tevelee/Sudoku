import Foundation

public protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible

    func moves(on board: SudokuBoard<Value>,
               layoutCache: inout Cache<SlicedGrid>,
               valueCache: inout Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>>
}

extension SudokuSolvingStrategy {
    func nextMove(on board: SudokuBoard<Value>,
                  layoutCache: inout Cache<SlicedGrid>,
                  valueCache: inout Cache<SudokuBoard<Value>>) async -> Move<Value>? {
        await moves(on: board, layoutCache: &layoutCache, valueCache: &valueCache).first
    }
}

public extension SudokuSolvingStrategy {
    func moves(on board: SudokuBoard<Value>) -> AsyncStream<Move<Value>> {
        var layoutCache = Cache(board.slicedGrid)
        var valueCache = Cache(board)
        return moves(on: board, layoutCache: &layoutCache, valueCache: &valueCache)
    }

    func nextMove(on board: SudokuBoard<Value>) async -> Move<Value>? {
        var layoutCache = Cache(board.slicedGrid)
        var valueCache = Cache(board)
        return await nextMove(on: board, layoutCache: &layoutCache, valueCache: &valueCache)
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

public protocol CachedComputation {
    associatedtype Subject
    associatedtype Value: Hashable

    static func compute(_ board: Subject) -> Value
}

struct PositionsInRowsCache: CachedComputation {
    static func compute(_ grid: SlicedGrid) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in Rows(grid: grid.grid) {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

struct PositionsInColumnsCache: CachedComputation {
    static func compute(_ grid: SlicedGrid) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in Columns(grid: grid.grid) {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

struct PositionsInRegionsCache: CachedComputation {
    static func compute(_ grid: SlicedGrid) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in grid.slices {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}

public struct Field<T> {
    let position: Position
    let value: T
}

extension Field: Equatable where T: Equatable {}
extension Field: Hashable where T: Hashable {}

struct RowFieldsCache<T: Hashable>: CachedComputation {
    static func compute(_ board: SudokuBoard<T>) -> [BoardSlice<T?>] {
        RowsCache.compute(board.slicedGrid).map { slice in
            slice.map { Field(position: $0, value: board[$0]) }
        }
    }
}

struct ColumnFieldsCache<T: Hashable>: CachedComputation {
    static func compute(_ board: SudokuBoard<T>) -> [BoardSlice<T?>] {
        ColumnsCache.compute(board.slicedGrid).map { slice in
            slice.map { Field(position: $0, value: board[$0]) }
        }
    }
}

struct RegionFieldsCache<T: Hashable>: CachedComputation {
    static func compute(_ board: SudokuBoard<T>) -> [BoardSlice<T?>] {
        RegionsCache.compute(board.slicedGrid).map { slice in
            slice.map { Field(position: $0, value: board[$0]) }
        }
    }
}

struct RowsCache: CachedComputation {
    static func compute(_ slicedGrid: SlicedGrid) -> [GridSlice] {
        Array(Rows(grid: slicedGrid.grid))
    }
}

struct ColumnsCache: CachedComputation {
    static func compute(_ slicedGrid: SlicedGrid) -> [GridSlice] {
        Array(Columns(grid: slicedGrid.grid))
    }
}

struct RegionsCache: CachedComputation {
    static func compute(_ slicedGrid: SlicedGrid) -> [GridSlice] {
        Array(slicedGrid.slices)
    }
}

public struct Cache<Subject> {
    private let subject: Subject
    private var objects: [ObjectIdentifier: AnyHashable] = [:]

    subscript<O: CachedComputation>(object: O.Type) -> O.Value where O.Subject == Subject {
        mutating get {
            let id = ObjectIdentifier(object)
            if let value = objects[id]?.base as? O.Value {
                return value
            }
            let value = O.compute(subject)
            objects[id] = AnyHashable(value)
            return value
        }
    }

    init(_ subject: Subject) {
        self.subject = subject
    }
}

extension Cache where Subject == SlicedGrid {
    var positionsToRows: [Position: GridSlice] {
        mutating get {
            self[PositionsInRowsCache.self]
        }
    }
    public mutating func row(for position: Position) -> GridSlice? {
        positionsToRows[position]
    }

    var positionsToColumns: [Position: GridSlice] {
        mutating get {
            self[PositionsInColumnsCache.self]
        }
    }
    public mutating func column(for position: Position) -> GridSlice? {
        positionsToColumns[position]
    }

    var positionsToRegions: [Position: GridSlice] {
        mutating get {
            self[PositionsInRegionsCache.self]
        }
    }
    public mutating func region(for position: Position) -> GridSlice? {
        positionsToRegions[position]
    }
}

extension Cache where Subject == SlicedGrid {
    mutating func rows() -> [GridSlice] {
        self[RowsCache.self]
    }
    mutating func columns() -> [GridSlice] {
        self[ColumnsCache.self]
    }
    mutating func regions() -> [GridSlice] {
        self[RegionsCache.self]
    }
}

extension Cache {
    mutating func rows<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[RowFieldsCache<Value>.self]
    }
    mutating func columns<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[ColumnFieldsCache<Value>.self]
    }
    mutating func regions<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[RegionFieldsCache<Value>.self]
    }
}

enum AvailableValue<Value: Hashable> {
    case fix(Value)
    case possible(Set<Value>)
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
