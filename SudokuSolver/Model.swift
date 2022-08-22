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
}

public struct Division<T> {
    public let slices: [Slice<T>]

    func map<K>(_ transform: (T) -> K) -> Division<K> {
        .init(slices: slices.map { slice in
            slice.map(transform)
        })
    }
}

extension Division: Equatable where T: Equatable {}
extension Division: Hashable where T: Hashable {}
extension Slice: Equatable where T: Equatable {}
extension Slice: Hashable where T: Hashable {}

struct Grid: Hashable {
    let size: Size

    var rows: Division<Position> {
        let rows = (0 ..< size.height).map { row in
            Slice(name: "Row \(row + 1)", items: (0 ..< size.width).map { column in
                Position(row: row, column: column)
            })
        }
        return .init(slices: rows)
    }

    var columns: Division<Position> {
        let columns = (0 ..< size.width).map { column in
            Slice(name: "Column \(column + 1)", items: (0 ..< size.height).map { row in
                Position(row: row, column: column)
            })
        }
        return .init(slices: columns)
    }

    func regions(allowsEmpty: Bool) -> Division<Position>? {
        if !allowsEmpty && gcd(size.width, size.height) == 1 {
            return nil
        }
        let sizeOfRegion = max(size.width, size.height)
        guard let (smallerSideOfRegion, largerSideOfRegion) = sizeOfRegion.mostEvenDivisors() else {
            return nil
        }
        if smallerSideOfRegion == 1 { // That's a row/column
            return allowsEmpty ? .init(slices: []) : nil
        }
        let regionWidth: Int
        let regionHeight: Int
        if size.width.isMultiple(of: smallerSideOfRegion) {
            regionWidth = smallerSideOfRegion
            regionHeight = largerSideOfRegion
        } else {
            regionWidth = largerSideOfRegion
            regionHeight = smallerSideOfRegion
        }

        let numberOfRegionRows = size.height / regionHeight
        let numberOfRegionColumns = size.width / regionWidth

        let regions = (0 ..< numberOfRegionRows).flatMap { row in
            (0 ..< numberOfRegionColumns).map { column in
                let positions = (0 ..< regionHeight).flatMap { y in
                    (0 ..< regionWidth).map { x in
                        Position(row: row * regionHeight + y,
                                 column: column * regionWidth + x)
                    }
                }
                return Slice(name: "Region \(row * numberOfRegionColumns + column + 1)", items: positions)
            }
        }
        return .init(slices: regions)
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
    func mostEvenDivisors() -> (Int, Int)? {
        var minDifference: Int = .max
        var result: (Int, Int)?
        for one in 1 ... self {
            for other in 1 ... self where one * other == self {
                let diff = abs(one - other)
                if diff < minDifference {
                    minDifference = diff
                    result = (Swift.min(one, other), Swift.max(one, other))
                }
            }
        }
        return result
    }
}
