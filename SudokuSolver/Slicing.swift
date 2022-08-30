import Foundation

public protocol SlicingStrategy {
    func slices(for grid: Grid) throws -> [GridSlice]
}

public struct NoSlicing: SlicingStrategy {
    public init() {}

    public func slices(for grid: Grid) throws -> [GridSlice] {
        []
    }
}

public struct RegularSudokuSlicing: SlicingStrategy {
    private let allowStripes: Bool

    public init(allowStripes: Bool = false) {
        self.allowStripes = allowStripes
    }

    public func slices(for grid: Grid) throws -> [GridSlice] {
        guard let regions = RectangularRegions(grid: grid, allowStripes: allowStripes) else {
            throw SlicingError.mustBeDivisibleToRegions
        }
        return Array(regions)
    }
}

public struct XSlicing: SlicingStrategy {
    public init() {}

    public func slices(for grid: Grid) throws -> [GridSlice] {
        guard grid.size.width == grid.size.height else {
            throw SlicingError.mustBeSquared
        }
        let size = grid.size.width
        return [
            GridSlice(name: "Diagonal SW-NE", items: (0 ..< size).map { Position(row: size - $0, column: $0) }),
            GridSlice(name: "Diagonal NW-SE", items: (0 ..< size).map { Position(row: $0, column: size - $0) })
        ]
    }
}

struct JigsawSlicing: SlicingStrategy {
    func slices(for grid: Grid) throws -> [GridSlice] {
        [] // TODO: figure out a jigsaw pattern factory
    }
}

public struct AnySlicing: SlicingStrategy {
    private let _slices: (Grid) throws -> [GridSlice]

    init(_ slices: @escaping (Grid) throws -> [GridSlice]) {
        _slices = slices
    }

    public init(_ slicing: SlicingStrategy) {
        self.init(slicing.slices)
    }

    public func slices(for grid: Grid) throws -> [GridSlice] {
        try _slices(grid)
    }
}

public enum SlicingError: Error, Equatable {
    case positionOutOfBounds
    case mustBeDivisibleToRegions
    case mustBeSquared
}
