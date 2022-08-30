import XCTest
@testable import SudokuSolver

final class SudokuBoardPrinterTests: XCTestCase {
    func test_whenPrintingBoardWithDefaultStyle_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, 4, 5, 6, 7, 8, 9],
            [nil, nil, nil, 7, 8, 9, 1, 2, 3],
            [nil, nil, nil, 1, 2, 3, 4, 5, 6],
            [2, 3, 4, 5, 6, 7, 8, 9, 1],
            [5, 6, 7, 8, 9, 1, 2, 3, 4],
            [8, 9, 1, 2, 3, 4, 5, 6, 7],
            [3, 4, 5, 6, 7, 8, 9, 1, 2],
            [6, 7, 8, 9, 1, 2, 3, 4, 5],
            [9, 1, 2, 3, 4, 5, 6, 7, 8]
        ])
        let printer = SudokuBoardPrinter()

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        +-----------+-----------+-----------+
        |           | 4   5   6 | 7   8   9 |
        |           |           |           |
        |           | 7   8   9 | 1   2   3 |
        |           |           |           |
        |           | 1   2   3 | 4   5   6 |
        +-----------+-----------+-----------+
        | 2   3   4 | 5   6   7 | 8   9   1 |
        |           |           |           |
        | 5   6   7 | 8   9   1 | 2   3   4 |
        |           |           |           |
        | 8   9   1 | 2   3   4 | 5   6   7 |
        +-----------+-----------+-----------+
        | 3   4   5 | 6   7   8 | 9   1   2 |
        |           |           |           |
        | 6   7   8 | 9   1   2 | 3   4   5 |
        |           |           |           |
        | 9   1   2 | 3   4   5 | 6   7   8 |
        +-----------+-----------+-----------+
        """)
    }

    func test_whenPrintingBoardWithSeparators_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(renderer: ASCIIRenderer(strokeSeparators: true))

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        +---+---+---+---+
        | 1 | 2 | 3 | 4 |
        +---+---+---+---+
        | 2 | 3 | 4 | 1 |
        +---+---+---+---+
        | 3 | 4 | 1 | 2 |
        +---+---+---+---+
        | 4 | 1 | 2 | 3 |
        +---+---+---+---+
        """)
    }

    func test_whenPrintingBoardWithoutPaddingAndSeparators_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(horizontalPadding: 0, verticalPadding: 0)

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        +---+---+
        |1 2|3 4|
        |   |   |
        |2 3|4 1|
        +---+---+
        |3 4|1 2|
        |   |   |
        |4 1|2 3|
        +---+---+
        """)
    }

    func test_whenPrintingBoardWithoutLines_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(drawBorders: false,
                                         drawSeparators: false,
                                         horizontalPadding: 0,
                                         verticalPadding: 0)

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        1234
        2341
        3412
        4123
        """)
    }

    func test_whenPrintingBoardWithLargerPadding_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(horizontalPadding: 3, verticalPadding: 1, renderer: ASCIIRenderer(strokeSeparators: true))

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        +-------+-------+-------+-------+
        |       |       |       |       |
        |   1   |   2   |   3   |   4   |
        |       |       |       |       |
        +-------+-------+-------+-------+
        |       |       |       |       |
        |   2   |   3   |   4   |   1   |
        |       |       |       |       |
        +-------+-------+-------+-------+
        |       |       |       |       |
        |   3   |   4   |   1   |   2   |
        |       |       |       |       |
        +-------+-------+-------+-------+
        |       |       |       |       |
        |   4   |   1   |   2   |   3   |
        |       |       |       |       |
        +-------+-------+-------+-------+
        """)
    }

    func test_whenPrintingBoardWithRoundedStyle_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(renderer: BoxedRenderer(style: .plain(.rounded)))

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        ╭───────┬───────╮
        │ 1   2 │ 3   4 │
        │       │       │
        │ 2   3 │ 4   1 │
        ├───────┼───────┤
        │ 3   4 │ 1   2 │
        │       │       │
        │ 4   1 │ 2   3 │
        ╰───────┴───────╯
        """)
    }

    func test_whenPrintingBoardWithBoxedStyle_thenGetsDrawnCorrectly() {
        // Given
        let board = try! SudokuBoard([
            [1, 2, 3, 4],
            [2, 3, 4, 1],
            [3, 4, 1, 2],
            [4, 1, 2, 3]
        ])
        let printer = SudokuBoardPrinter(renderer: BoxedRenderer(style: .leveled(.singleAndDouble)))

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
        ╔═══╤═══╦═══╤═══╗
        ║ 1 │ 2 ║ 3 │ 4 ║
        ╟───┼───╫───┼───╢
        ║ 2 │ 3 ║ 4 │ 1 ║
        ╠═══╪═══╬═══╪═══╣
        ║ 3 │ 4 ║ 1 │ 2 ║
        ╟───┼───╫───┼───╢
        ║ 4 │ 1 ║ 2 │ 3 ║
        ╚═══╧═══╩═══╧═══╝
        """)
    }
}
