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

public struct SudokuBoard<Value> {
    var rawData: [[Value?]]

    private let positionsOfRowSlices: Rows
    private let positionsOfColumnSlices: Columns
    private let positionsOfRegionSlices: Regions

    public var rows: some Sequence<Slice<Value?>> {
        values(from: positionsOfRowSlices)
    }
    public var columns: some Sequence<Slice<Value?>> {
        values(from: positionsOfColumnSlices)
    }
    public var regions: some Sequence<Slice<Value?>> {
        values(from: positionsOfRegionSlices)
    }

    private func values(from division: some Sequence<Slice<Position>>) -> some Sequence<Slice<Value?>> {
        division.lazy.map {
            $0.map { self[$0] }
        }
    }

    public let width: Int
    public let height: Int

    public var values: some Sequence<Value?> {
        rawData.lazy.flatMap { $0.lazy }
    }

    public init(_ rows: [[Value?]], allowsEmptyRegions: Bool = false) throws {
        if rows.isEmpty || rows.contains(where: \.isEmpty) {
            throw IncorrectSizeError.mustHavePositiveSize
        }
        self.rawData = rows
        self.height = rows.count
        self.width = rows[0].count
        let grid = Grid(size: Size(width: width, height: height))
        self.positionsOfRowSlices = Rows(grid: grid)
        self.positionsOfColumnSlices = Columns(grid: grid)
        guard let regions = Regions(grid: grid, allowsEmpty: allowsEmptyRegions) else {
            throw IncorrectSizeError.mustBeDivisibleToRegions
        }
        self.positionsOfRegionSlices = regions
    }

    public init(partiallyComplete: [[Value?]] = [],
                width: Int = 9,
                height: Int = 9,
                allowsEmptyRegions: Bool = false) throws {
        guard width > 0, height > 0 else {
            throw IncorrectSizeError.mustHavePositiveSize
        }
        let rows = partiallyComplete.map {
            $0.padded(with: nil, desiredSize: width)
        }.padded(with: Array(repeating: nil, count: width), desiredSize: height)
        try self.init(rows, allowsEmptyRegions: allowsEmptyRegions)
    }

    func firstIncompletePosition() -> Position? {
        for (rowIndex, row) in rawData.enumerated() {
            for (columnIndex, value) in row.enumerated() {
                if value == nil {
                    return Position(row: rowIndex, column: columnIndex)
                }
            }
        }
        return nil
    }

    subscript(position: Position) -> Value? {
        get {
            rawData[position.row][position.column]
        }
        set {
            rawData[position.row][position.column] = newValue
        }
    }
}

extension SudokuBoard: Equatable where Value: Equatable {
    public static func == (lhs: SudokuBoard, rhs: SudokuBoard) -> Bool {
        lhs.rawData == rhs.rawData
    }
}

extension SudokuBoard: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawData)
    }
}

extension SudokuBoard: CustomStringConvertible where Value: CustomStringConvertible {
    public var description: String {
        "\n\(SudokuBoardPrinter().print(self))\n"
    }
}

public enum IncorrectSizeError: Error, Equatable {
    case mustHavePositiveSize
    case mustBeDivisibleToRegions
}

private extension Array {
    func padded(with element: Element, desiredSize: Int) -> Self {
        guard count != desiredSize else {
            return self
        }
        return self + Array(repeating: element, count: desiredSize - count)
    }
}
