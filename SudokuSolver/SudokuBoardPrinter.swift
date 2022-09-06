import Foundation
import Algorithms

public enum GridElement {
    case content((any CustomStringConvertible)?)
    case spacing
    case border(Border)

    static func border(top: Border.Style, leading: Border.Style, bottom: Border.Style, trailing: Border.Style) -> GridElement {
        .border(Border(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
}

public struct Border: Equatable {
    public enum Style: Equatable, Comparable {
        case none, soft, hard

        func downgraded() -> Style {
            if case .hard = self {
                return .soft
            }
            return .none
        }
    }

    public let top: Style
    public let leading: Style
    public let bottom: Style
    public let trailing: Style

    func downgraded() -> Border {
        Border(top: top.downgraded(),
               leading: leading.downgraded(),
               bottom: bottom.downgraded(),
               trailing: trailing.downgraded())
    }
}

public protocol SudokuComponentRenderer {
    func render(_ element: GridElement) -> String
}

public class ASCIIRenderer: SudokuComponentRenderer {
    private let threshold: Border.Style

    public init(strokeSeparators: Bool = false) {
        self.threshold = strokeSeparators ? .soft : .hard
    }

    public func render(_ element: GridElement) -> String {
        switch element {
            case .spacing: return " "
            case .content(let value): return value?.description ?? " "
            case .border(let border): return render(border)
        }
    }

    private func render(_ border: Border) -> String {
        let horizontal = border.leading >= threshold || border.trailing >= threshold
        let vertical = border.top >= threshold || border.bottom >= threshold
        switch (horizontal, vertical) {
            case (true, true): return "+"
            case (false, true): return "|"
            case (true, false): return "-"
            case (false, false): return " "
        }
    }
}

public class BoxedRenderer: SudokuComponentRenderer {
    public enum Style: Equatable {
        case plain(PlainStyle)
        case leveled(LeveledStyle)
    }
    public enum PlainStyle: Equatable {
        case rounded
        case edged
    }
    public enum LeveledStyle: Equatable {
        case thinAndHeavy
        case singleAndDouble
    }

    private let style: Style

    public init(style: Style = .plain(.rounded)) {
        self.style = style
    }

    public func render(_ element: GridElement) -> String {
        switch element {
            case .spacing: return " "
            case .content(let value): return value?.description ?? " "
            case .border(let border):
                switch style {
                    case .plain:
                        return render(border.downgraded())
                    case .leveled:
                        return render(border)
                }
        }
    }

    private func render(_ border: Border) -> String {
        switch (border.top, border.leading, border.bottom, border.trailing) {
            case (.none, .none, .none, .none): return " "

            case (.none, .soft, .none, .soft): return "─"
            case (.none, .hard, .none, .hard): return style == .leveled(.thinAndHeavy) ? "━" : "═"

            case (.soft, .none, .soft, .none): return "│"
            case (.hard, .none, .hard, .none): return style == .leveled(.thinAndHeavy) ? "┃" : "║"

            case (.soft, .soft, .none, .none): return style == .plain(.rounded) ? "╯" : "┘"
            case (.none, .soft, .soft, .none): return style == .plain(.rounded) ? "╮" : "┐"
            case (.none, .none, .soft, .soft): return style == .plain(.rounded) ? "╭" : "┌"
            case (.soft, .none, .none, .soft): return style == .plain(.rounded) ? "╰" : "└"

            case (.hard, .hard, .none, .none): return style == .leveled(.thinAndHeavy) ? "┛" : "╝"
            case (.none, .hard, .hard, .none): return style == .leveled(.thinAndHeavy) ? "┓" : "╗"
            case (.none, .none, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "┏" : "╔"
            case (.hard, .none, .none, .hard): return style == .leveled(.thinAndHeavy) ? "┗" : "╚"

            case (.none, .soft, .soft, .soft): return "┬"
            case (.soft, .none, .soft, .soft): return "├"
            case (.soft, .soft, .none, .soft): return "┴"
            case (.soft, .soft, .soft, .none): return "┤"

            case (.none, .hard, .soft, .hard): return style == .leveled(.thinAndHeavy) ? "┯" : "╤"
            case (.hard, .none, .hard, .soft): return style == .leveled(.thinAndHeavy) ? "┠" : "╟"
            case (.soft, .hard, .none, .hard): return style == .leveled(.thinAndHeavy) ? "┷" : "╧"
            case (.hard, .soft, .hard, .none): return style == .leveled(.thinAndHeavy) ? "┨" : "╢"

            case (.none, .hard, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "┳" : "╦"
            case (.hard, .none, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "┣" : "╠"
            case (.hard, .hard, .none, .hard): return style == .leveled(.thinAndHeavy) ? "┻" : "╩"
            case (.hard, .hard, .hard, .none): return style == .leveled(.thinAndHeavy) ? "┫" : "╣"

            case (.soft, .soft, .soft, .soft): return "┼"
            case (.hard, .hard, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "╊" : "╬"

            case (.hard, .soft, .hard, .soft): return style == .leveled(.thinAndHeavy) ? "╂" : "╫"
            case (.soft, .hard, .soft, .hard): return style == .leveled(.thinAndHeavy) ? "┿" : "╪"

            case (.soft, .soft, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "╆" : "╔"
            case (.hard, .soft, .soft, .hard): return style == .leveled(.thinAndHeavy) ? "╄" : "╚"
            case (.hard, .hard, .soft, .soft): return style == .leveled(.thinAndHeavy) ? "╃" : "╝"
            case (.soft, .hard, .hard, .soft): return style == .leveled(.thinAndHeavy) ? "╅" : "╗"

            case (.soft, .hard, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "╈" : "╦"
            case (.hard, .soft, .hard, .hard): return style == .leveled(.thinAndHeavy) ? "╊" : "╠"
            case (.hard, .hard, .soft, .hard): return style == .leveled(.thinAndHeavy) ? "╇" : "╩"
            case (.hard, .hard, .hard, .soft): return style == .leveled(.thinAndHeavy) ? "╉" : "╣"


            default:
                assertionFailure("Unknown symbol")
                return " "
        }
    }
}

public final class SudokuBoardPrinter {
    private let borderSize: Int
    private let drawSeparators: Bool
    private let horizontalPadding: Int
    private let verticalPadding: Int
    private let renderer: any SudokuComponentRenderer

    init(drawBorders: Bool = true,
         drawSeparators: Bool = true,
         horizontalPadding: Int = 1,
         verticalPadding: Int = 0,
         renderer: any SudokuComponentRenderer = ASCIIRenderer()) {
        self.borderSize = drawBorders ? 1 : 0
        self.drawSeparators = drawSeparators
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.renderer = renderer
    }

    private let newLine = "\n"

    func print<T: Hashable & CustomStringConvertible>(_ board: SudokuBoard<T>) -> String {
        var result: String = ""
        var layoutCache = Cache(board.slicedGrid)
        var valueCache = Cache(board)
        if layoutCache.rows().isEmpty {
            for row in valueCache.rows() {
                Swift.print(row.items.map { render(.content($0.value)) }.joined(separator: render(.spacing)), to: &result)
            }
        } else {
            var regions: [Position: String] = [:]
            for slice in layoutCache.regions() {
                for item in slice.items {
                    regions[item] = slice.name
                }
            }

            let vertical = tiles(count: board.height)
            for row in vertical {
                var rowToPrint = ""
                var rowToPrintAroundContentRow = ""
                let horizontal = tiles(count: board.width)
                for column in horizontal {
                    let content = render(component(row: row, column: column, board: board, regions: regions))

                    // add horizontal padding
                    switch (row, column) {
                        case (.outerSeparator, .content), (.innerSeparator, .content):
                            rowToPrint += content.repeated(2 * horizontalPadding + 1)
                        case (.content, .content):
                            rowToPrint += render(.spacing).repeated(horizontalPadding)
                            rowToPrint += content
                            rowToPrint += render(.spacing).repeated(horizontalPadding)
                        default:
                            rowToPrint += content
                    }

                    // add vertical padding
                    switch (row, column) {
                        case (.content, .content):
                            rowToPrintAroundContentRow += render(.spacing).repeated(horizontalPadding * 2 + 1)
                        case (.content, .outerSeparator), (.content, .innerSeparator):
                            rowToPrintAroundContentRow += content
                        default:
                            break
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

    private func tiles(count: Int) -> some Sequence<Tile> {
        let items = (0 ..< count).lazy
        let withSeparators: AnySequence<Tile>
        if drawSeparators {
            withSeparators = AnySequence(items.interspersedMap(Tile.content, with: Tile.innerSeparator))
        } else {
            withSeparators = AnySequence(items.map(Tile.content))
        }
        return withSeparators
            .prepended(with: .outerSeparator(.leading), count: borderSize)
            .appended(with: .outerSeparator(.trailing), count: borderSize)
    }

    private func render(_ element: GridElement) -> String {
        renderer.render(element)
    }

    private func component<T: CustomStringConvertible>(row: Tile, column: Tile, board: SudokuBoard<T>, regions: [Position: String]) -> GridElement {
        switch (row, column) {
            case let (.outerSeparator(row), .outerSeparator(column)):
                return .border(top: row == .leading ? .none : .hard,
                               leading: column == .leading ? .none : .hard,
                               bottom: row == .trailing ? .none : .hard,
                               trailing: column == .trailing ? .none : .hard)
            case (.content, .outerSeparator):
                return .border(top: .hard,
                               leading: .none,
                               bottom: .hard,
                               trailing: .none)
            case (.outerSeparator, .content):
                return .border(top: .none,
                               leading: .hard,
                               bottom: .none,
                               trailing: .hard)
            case let (.innerSeparator(r1, r2), .outerSeparator(side)):
                let column = side == .leading ? 0 : board.width - 1
                let p1 = Position(row: r1, column: column)
                let p2 = Position(row: r2, column: column)
                let needsHardSeparator = regions[p1] != regions[p2]
                return .border(top: .hard,
                               leading: side == .leading ? .none : needsHardSeparator ? .hard : .soft,
                               bottom: .hard,
                               trailing: side == .trailing ? .none : needsHardSeparator ? .hard : .soft)
            case let (.outerSeparator(side), .innerSeparator(c1, c2)):
                let row = side == .leading ? 0 : board.height - 1
                let p1 = Position(row: row, column: c1)
                let p2 = Position(row: row, column: c2)
                let needsHardSeparator = regions[p1] != regions[p2]
                return .border(top: side == .leading ? .none : needsHardSeparator ? .hard : .soft,
                               leading: .hard,
                               bottom: side == .trailing ? .none : needsHardSeparator ? .hard : .soft,
                               trailing: .hard)
            case let (.innerSeparator(r1, r2), .innerSeparator(c1, c2)):
                let topLeading = Position(row: r1, column: c1)
                let topTrailing = Position(row: r1, column: c2)
                let bottomLeading = Position(row: r2, column: c1)
                let bottomTrailing = Position(row: r2, column: c2)
                return .border(top: regions[topLeading] == regions[topTrailing] ? .soft : .hard,
                               leading: regions[topLeading] == regions[bottomLeading] ? .soft : .hard,
                               bottom: regions[bottomLeading] == regions[bottomTrailing] ? .soft : .hard,
                               trailing: regions[topTrailing] == regions[bottomTrailing] ? .soft : .hard)
            case let (.content(row), .innerSeparator(c1, c2)):
                let p1 = Position(row: row, column: c1)
                let p2 = Position(row: row, column: c2)
                return .border(top: regions[p1] == regions[p2] ? .soft : .hard,
                               leading: .none,
                               bottom: regions[p1] == regions[p2] ? .soft : .hard,
                               trailing: .none)
            case let (.innerSeparator(r1, r2), .content(column)):
                let p1 = Position(row: r1, column: column)
                let p2 = Position(row: r2, column: column)
                return .border(top: .none,
                               leading: regions[p1] == regions[p2] ? .soft : .hard,
                               bottom: .none,
                               trailing: regions[p1] == regions[p2] ? .soft : .hard)
            case let (.content(row), .content(column)):
                let position = Position(row: row, column: column)
                return .content(board[position])
        }
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
