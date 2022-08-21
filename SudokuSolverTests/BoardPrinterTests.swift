import XCTest
@testable import SudokuSolver

final class BoardPrinterTests: XCTestCase {
    func test_whenCreatingValidFullBoard_thenInitializationSucceeds() throws {
        // Given
        let board = try! RegularSudokuBoard([
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
        let printer = BoardPrinter()

        // When
        let result = printer.print(board)

        // Then
        XCTAssertEqual(result, """
              | 4 5 6 | 7 8 9
              | 7 8 9 | 1 2 3
              | 1 2 3 | 4 5 6
        - - - + - - - + - - -
        2 3 4 | 5 6 7 | 8 9 1
        5 6 7 | 8 9 1 | 2 3 4
        8 9 1 | 2 3 4 | 5 6 7
        - - - + - - - + - - -
        3 4 5 | 6 7 8 | 9 1 2
        6 7 8 | 9 1 2 | 3 4 5
        9 1 2 | 3 4 5 | 6 7 8
        """)
    }
}

