import Foundation
import Algorithms

// - Valid board generator
// - Jigsaw region generator
// - Board scanner (reader) from string/image input
// - UI

public typealias BoardSlice<Value> = Slice<Field<Value>>

public struct SudokuBoard<Value> {
    // TODO: store non optionals, because AvailableValue.possible can replace nil
    private var rawData: [[Value?]]

    let slicedGrid: SlicedGrid

    public var width: Int { slicedGrid.grid.size.width }
    public var height: Int { slicedGrid.grid.size.height }

    public var values: some Sequence<Value?> {
        rawData.lazy.flatMap { $0.lazy }
    }

    public init(_ rows: [[Value?]], slicing: SlicingStrategy = RegularSudokuSlicing()) throws {
        if rows.isEmpty || rows.contains(where: \.isEmpty) {
            throw IncorrectSizeError.mustHavePositiveSize
        }
        self.rawData = rows
        let width = rows[0].count
        let height = rows.count
        let grid = Grid(width: width, height: height)
        let slices = try slicing.slices(for: grid)
        guard slices.flatMap(\.items).allSatisfy(grid.contains) else {
            throw SlicingError.positionOutOfBounds
        }
        self.slicedGrid = SlicedGrid(grid: grid, slices: slices)
    }

    public init(partiallyComplete: [[Value?]] = [],
                width: Int = 9,
                height: Int = 9,
                slicing: SlicingStrategy = RegularSudokuSlicing()) throws {
        guard width > 0, height > 0 else {
            throw IncorrectSizeError.mustHavePositiveSize
        }
        guard partiallyComplete.count <= height, partiallyComplete.allSatisfy({ $0.count <= width }) else {
            throw IncorrectSizeError.valuesExceedProvidedSize
        }
        let rows = partiallyComplete.map {
            $0.padded(with: nil, desiredSize: width)
        }.padded(with: Array(repeating: nil, count: width), desiredSize: height)
        try self.init(rows, slicing: slicing)
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

    func value(at position: Position) -> Value? {
        self[position]
    }

    func contains(position: Position) -> Bool {
        Grid(width: width, height: height).contains(position: position)
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

extension SudokuBoard: CustomStringConvertible where Value: CustomStringConvertible, Value: Hashable {
    public var description: String {
        "\n\(SudokuBoardPrinter().print(self))\n"
    }
}

public enum IncorrectSizeError: Error, Equatable {
    case mustHavePositiveSize
    case valuesExceedProvidedSize
}

private extension Array {
    func padded(with element: Element, desiredSize: Int) -> Self {
        guard count != desiredSize else {
            return self
        }
        return self + Array(repeating: element, count: desiredSize - count)
    }
}
