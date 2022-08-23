import Foundation

public typealias Count = Int
public typealias Index = Int

public struct Size: Hashable {
    public let width: Int
    public let height: Int
}

public struct Position: Hashable, CustomStringConvertible {
    public let row: Int
    public let column: Int

    public var description: String {
        "(\(row),\(column))"
    }
}

public enum Segment: Equatable {
    case row(Index)
    case column(Index)
    case region(Index)
}

public struct Slice<T> {
    public let name: String
    public let items: [T]

    func map<K>(_ transform: (T) -> K) -> Slice<K> {
        .init(name: name, items: items.map(transform))
    }

    func compactMap<K>(_ transform: (T) -> K?) -> Slice<K> {
        .init(name: name, items: items.compactMap(transform))
    }
}

extension Slice: Equatable where T: Equatable {}
extension Slice: Hashable where T: Hashable {}

struct Grid: Hashable {
    let size: Size

    init(width: Int, height: Int) {
        size = Size(width: width, height: height)
    }

    func contains(position: Position) -> Bool {
        (0 ..< size.width).contains(position.column) && (0 ..< size.height).contains(position.row)
    }
}

struct Rows: Sequence {
    let grid: Grid

    func makeIterator() -> Iterator {
        Iterator(grid: grid)
    }

    struct Iterator: IteratorProtocol {
        let grid: Grid
        var row: Int = 0

        mutating func next() -> Slice<Position>? {
            defer { row += 1 }
            guard row < grid.numberOfRows else {
                return nil
            }
            let items = (0 ..< grid.numberOfColumns).map { column in
                Position(row: row, column: column)
            }
            return .init(name: "Row \(row + 1)", items: items)
        }
    }
}

struct Columns: Sequence {
    let grid: Grid

    func makeIterator() -> Iterator {
        Iterator(grid: grid)
    }

    struct Iterator: IteratorProtocol {
        let grid: Grid
        var column: Int = 0

        mutating func next() -> Slice<Position>? {
            defer { column += 1 }
            guard column < grid.numberOfColumns else {
                return nil
            }
            let items = (0 ..< grid.numberOfRows).map { row in
                Position(row: row, column: column)
            }
            return .init(name: "Column \(column + 1)", items: items)
        }
    }
}

private extension Grid {
    var numberOfRows: Int { size.height }
    var numberOfColumns: Int { size.width }
}

struct RectangularRegions: Sequence {
    private let regionSize: Size
    private let numberOfRegionRows: Int
    private let numberOfRegionColumns: Int

    init?(grid: Grid, allowStripes: Bool) {
        if !allowStripes && gcd(grid.size.width, grid.size.height) == 1 {
            return nil
        }
        let sizeOfRegion = Swift.max(grid.size.width, grid.size.height)
        let (smallerSideOfRegion, largerSideOfRegion) = sizeOfRegion.mostEvenDivisors()
        if !allowStripes, smallerSideOfRegion == 1 {
            return nil
        }
        if grid.size.width.isMultiple(of: smallerSideOfRegion) {
            regionSize = Size(width: smallerSideOfRegion, height: largerSideOfRegion)
        } else {
            regionSize = Size(width: largerSideOfRegion, height: smallerSideOfRegion)
        }
        numberOfRegionRows = grid.size.height / regionSize.height
        numberOfRegionColumns = grid.size.width / regionSize.width
    }

    func makeIterator() -> Iterator {
        Iterator(regionSize: regionSize,
                 numberOfRegionRows: numberOfRegionRows,
                 numberOfRegionColumns: numberOfRegionColumns)
    }

    struct Iterator: IteratorProtocol {
        let regionSize: Size
        let numberOfRegionRows: Int
        let numberOfRegionColumns: Int

        var row: Int = 0
        var column: Int = 0

        mutating func next() -> Slice<Position>? {
            guard row < numberOfRegionRows, column < numberOfRegionColumns else {
                return nil
            }
            defer {
                if column == numberOfRegionColumns - 1 {
                    column = 0
                    row += 1
                } else {
                    column += 1
                }
            }
            let positions = (0 ..< regionSize.height).flatMap { y in
                (0 ..< regionSize.width).map { x in
                    Position(row: row * regionSize.height + y,
                             column: column * regionSize.width + x)
                }
            }
            return Slice(name: "Region \(row * numberOfRegionColumns + column + 1)", items: positions)
        }
    }
}

private func gcd(_ m: Int, _ n: Int) -> Int {
    var a: Int = 0
    var b: Int = max(m, n)
    var r: Int = min(m, n)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

private extension Int {
    func mostEvenDivisors() -> (Int, Int) {
        var minDifference: Int = .max
        var result: (Int, Int) = (1, self)
        for one in 1 ... self {
            for other in 1 ... self where one * other == self {
                let diff = abs(one - other)
                if diff < minDifference {
                    minDifference = diff
                    result = (Swift.min(one, other), Swift.max(one, other))
                    if diff <= 1 {
                        return result
                    }
                }
            }
        }
        return result
    }
}
