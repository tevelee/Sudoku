import Foundation

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
//    mutating func regions<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
//        self[RegionFieldsCache<Value>.self]
//    }
}
