import Foundation
import Algorithms

// Project TODOs
// - Quick solver for first solution (backtrace)
// - Solver with strategies
// - Diagnostics for solver (highlighting next region and logical step)
// - Valid board generator
// - Board scanner (reader) from string/image input
// - UI
// - Irregular board types: X board, board with variable shaped regions, NxM size, etc.
// - Codify advanced rules: one in a row/col/seg, knight moves, diagonals, odds/evens. Validator/Solver can work against these rules

public protocol SudokuBoard {
    var rows: [[Value]] { get }

    var width: Int { get }
    var height: Int { get }
}

public struct RegularSudokuBoard: SudokuBoard, Hashable, CustomStringConvertible {
    public var rows: [[Value]]

    public let width: Int = 9
    public let height: Int = 9

    public init(_ rows: [[Value]]) throws {
        let validator = BoardValidator(rows: rows)
        try validator.validateValues()
        try validator.validateNumberOfRows()
        try validator.validateNumberOfColumnsInAllRows()
        try validator.validateDuplicateValuesInRows()
        try validator.validateDuplicateValuesInColumns()
        try validator.validateDuplicateValuesInRegions()
        self.rows = rows
    }

    public init(partiallyComplete: [[Value]]) throws {
        let rows = partiallyComplete.map {
            $0.padded(with: nil, desiredSize: 9)
        }.padded(with: Array(repeating: nil, count: 9), desiredSize: 9)
        try self.init(rows)
    }

    public var description: String {
        let board = BoardPrinter().print(self)
        return "RegularBoard(\n\(board)\n)"
    }

    func firstIncompletePosition() -> Position? {
        for (rowIndex, row) in rows.enumerated() {
            for (columnIndex, value) in row.enumerated() {
                if value == nil {
                    return Position(row: rowIndex, column: columnIndex)
                }
            }
        }
        return nil
    }

    subscript(position: Position) -> Value {
        get {
            rows[position.row][position.column]
        }
        set {
            rows[position.row][position.column] = newValue
        }
    }
}

struct Position {
    let row: Int
    let column: Int
}

public typealias Value = Int?
public typealias Count = Int
public typealias RowIndex = Int
public typealias ColumnIndex = Int
public typealias RegionIndex = Int

public enum Segment: Equatable {
    case row(RowIndex)
    case column(ColumnIndex)
    case region(RegionIndex)
}

public enum IncorrectSizeError: Error, Equatable {
    case incorrectNumberOfRows(Int)
    case incorrectNumberOfColumns(Int, row: Int)
}

public struct DuplicateValuesError: Error, Equatable {
    public let duplicates: [DuplicateValueError]
}

public struct DuplicateValueError: Error, Equatable {
    public let value: Value
    public let segment: Segment
}

public struct IncorrectValueError: Error, Equatable {
    public let value: Value
    public let row: RowIndex
    public let column: ColumnIndex
}

struct BoardValidator {
    let rows: [[Value]]

    func validateNumberOfRows() throws {
        let numberOfRows = rows.count
        guard numberOfRows == 9 else {
            throw IncorrectSizeError.incorrectNumberOfRows(numberOfRows)
        }
    }

    func validateNumberOfColumnsInAllRows() throws {
        for rowIndex in rows.indices {
            let numberOfColumns = rows[rowIndex].count
            guard numberOfColumns == 9 else {
                throw IncorrectSizeError.incorrectNumberOfColumns(numberOfColumns, row: rowIndex)
            }
        }
    }

    func validateValues() throws {
        let validValues: Set<Value> = [nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        for (rowIndex, row) in rows.enumerated() {
            for (columnIndex, value) in row.enumerated() {
                if !validValues.contains(value) {
                    throw IncorrectValueError(value: value, row: rowIndex, column: columnIndex)
                }
            }
        }
    }

    typealias CountsOfValues = [Value: Count]

    func validateDuplicateValuesInRows() throws {
        if let duplicate = findDuplicates(in: rows) {
            throw DuplicateValueError(value: duplicate.value, segment: .row(duplicate.index))
        }
    }

    func validateDuplicateValuesInColumns() throws {
        let columns = (0 ..< 9).map { columnIndex in
            rows.map { $0[columnIndex] }
        }
        if let duplicate = findDuplicates(in: columns) {
            throw DuplicateValueError(value: duplicate.value, segment: .column(duplicate.index))
        }
    }

    func validateDuplicateValuesInRegions() throws {
        var regions: [[Value]] = []
        for rowIndex in stride(from: 0, to: 9, by: 3) {
            for columnIndex in stride(from: 0, to: 9, by: 3) {
                let region = [0, 1, 2].flatMap { rowOffset in
                    [0, 1, 2].map { columnOffset in
                        rows[rowIndex + rowOffset][columnIndex + columnOffset]
                    }
                }
                regions.append(region)
            }
        }
        if let duplicate = findDuplicates(in: regions) {
            throw DuplicateValueError(value: duplicate.value, segment: .region(duplicate.index))
        }
    }

    private func findDuplicates(in values: [[Value]]) -> (value: Value, index: Int)? {
        var map: [RegionIndex: CountsOfValues] = [:]
        for (index, values) in values.enumerated() {
            for value in values {
                guard let value = value else {
                    continue
                }
                let count = map[index]?[value] ?? 0
                if count == 1 {
                    return (value, index)
                }
                map[index, default: [:]][value] = count + 1
            }
        }
        return nil
    }
}

private extension Array {
    func padded(with element: Element, desiredSize: Int) -> Self {
        guard count != desiredSize else {
            return self
        }
        return self + Array(repeating: element, count: desiredSize - count)
    }
}
