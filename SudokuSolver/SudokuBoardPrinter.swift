import Foundation
import Algorithms

public final class SudokuBoardPrinter {
    let useBorder: Bool
    let horizontalPadding: Int
    let verticalPadding: Int

    init(useBorder: Bool = true,
        horizontalPadding: Int = 1,
        verticalPadding: Int = 0) {
        self.useBorder = useBorder
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    private let emptyPlaceholder = " "
    private let spacing = " "

    private let horizontalBorder = "-"
    private let verticalBorder = "|"
    private let intersectingBorder = "+"

    private let newLine = "\n"

    func print<T: CustomStringConvertible>(_ board: SudokuBoard<T>) -> String {
        var result: String = ""
        if Array(board.positionsOfRegionSlices).isEmpty {
            for row in board.rows {
                Swift.print(row.items.map { $0?.description ?? emptyPlaceholder }.joined(separator: spacing), to: &result)
            }
        } else {
            var map: [Position: String] = [:]
            for slice in board.positionsOfRegionSlices {
                for item in slice.items {
                    map[item] = slice.name
                }
            }

            let borderCount = useBorder ? 1 : 0
            let vertical = (0 ..< board.height)
                .lazy
                .interspersedMap(Tile.content, with: Tile.innerSeparator)
                .prepended(with: .outerSeparator(.leading), count: borderCount)
                .appended(with: .outerSeparator(.trailing), count: borderCount)
            for row in vertical {
                var rowToPrint = ""
                var rowToPrintAroundContentRow = ""
                let horizontal = (0 ..< board.width)
                    .lazy
                    .interspersedMap(Tile.content, with: Tile.innerSeparator)
                    .prepended(with: .outerSeparator(.leading), count: borderCount)
                    .appended(with: .outerSeparator(.trailing), count: borderCount)
                for column in horizontal {
                    switch (row, column) {
                        case (.outerSeparator, .outerSeparator):
                            rowToPrint += intersectingBorder
                        case (.content, .outerSeparator):
                            rowToPrint += verticalBorder
                            rowToPrintAroundContentRow += verticalBorder
                        case let (.innerSeparator(r1, r2), .outerSeparator(side)):
                            let column = side == .leading ? 0 : board.width - 1
                            let p1 = Position(row: r1, column: column)
                            let p2 = Position(row: r2, column: column)
                            rowToPrint += map[p1] == map[p2] ? verticalBorder : intersectingBorder
                        case (.outerSeparator, .content):
                            rowToPrint += horizontalBorder.repeated(2 * horizontalPadding + 1)
                        case let (.outerSeparator(side), .innerSeparator(c1, c2)):
                            let row = side == .leading ? 0 : board.height - 1
                            let p1 = Position(row: row, column: c1)
                            let p2 = Position(row: row, column: c2)
                            rowToPrint += map[p1] == map[p2] ? horizontalBorder : intersectingBorder
                        case let (.innerSeparator(r1, r2), .innerSeparator(c1, c2)):
                            let p1 = Position(row: r1, column: c1)
                            let p2 = Position(row: r2, column: c1)
                            let p3 = Position(row: r1, column: c2)
                            let p4 = Position(row: r2, column: c2)
                            let needsHorizontal = map[p1] != map[p2] || map[p3] != map[p4]
                            let needsVertical = map[p1] != map[p3] || map[p2] != map[p4]
                            switch (needsHorizontal, needsVertical) {
                                case (true, true):
                                    rowToPrint += intersectingBorder
                                case (true, false):
                                    rowToPrint += horizontalBorder
                                case (false, true):
                                    rowToPrint += verticalBorder
                                case (false, false):
                                    rowToPrint += spacing
                            }
                        case let (.content(row), .content(column)):
                            let position = Position(row: row, column: column)
                            rowToPrint += spacing.repeated(horizontalPadding)
                            rowToPrint += board[position]?.description ?? emptyPlaceholder
                            rowToPrint += spacing.repeated(horizontalPadding)
                            rowToPrintAroundContentRow += spacing.repeated(horizontalPadding * 2 + 1)
                        case let (.content(row), .innerSeparator(c1, c2)):
                            let p1 = Position(row: row, column: c1)
                            let p2 = Position(row: row, column: c2)
                            let output = map[p1] == map[p2] ? spacing : verticalBorder
                            rowToPrint += output
                            rowToPrintAroundContentRow += output
                        case let (.innerSeparator(r1, r2), .content(column)):
                            let p1 = Position(row: r1, column: column)
                            let p2 = Position(row: r2, column: column)
                            rowToPrint += (map[p1] == map[p2] ? spacing : horizontalBorder).repeated(2 * horizontalPadding + 1)
                    }
                }
                if rowToPrintAroundContentRow.isEmpty {
                    Swift.print(rowToPrint, to: &result)
                } else {
                    result += rowToPrintAroundContentRow.appended(with: newLine).repeated(verticalPadding)
                    Swift.print(rowToPrint, to: &result)
                    result += rowToPrintAroundContentRow.appended(with: newLine).repeated(verticalPadding)
                }
            }
            result.removeLast()
        }
        return result
    }
}

private extension Sequence {
    func prepended(with element: Element, count: Int) -> some Sequence<Element> {
        Array(repeating: element, count: count).concat(self)
    }

    func appended(with element: Element, count: Int) -> some Sequence<Element> {
        self.concat(Array(repeating: element, count: count))
    }

    func concat(_ other: some Sequence<Element>) -> some Sequence<Element> {
        chain(self, other)
    }
}

private enum Tile: Equatable {
    case content(Int)
    case innerSeparator(Int,Int)
    case outerSeparator(Side)
}

private enum Side: Equatable {
    case leading, trailing
}

private extension String {
    func repeated(_ count: Int) -> String {
        Array(repeating: self, count: count).joined()
    }

    func appended(with other: String) -> String {
        self + other
    }
}
