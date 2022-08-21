import XCTest
@testable import SudokuSolver

final class RegularBoardInitializerTests: XCTestCase {
    func test_whenCreatingBoardWithEmptyColumns_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([])
        }
        XCTAssertEqual(error, .incorrectNumberOfRows(0))
    }

    func test_whenCreatingBoardWithInvalidNumber_thenInitializationThrows() throws {
        let error: IncorrectValueError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [13]
            ])
        }
        XCTAssertEqual(error.value, 13)
        XCTAssertEqual(error.row, 0)
        XCTAssertEqual(error.column, 0)
    }

    func test_whenCreatingBoardWithTooFewRows_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3]
            ])
        }
        XCTAssertEqual(error, .incorrectNumberOfRows(1))
    }

    func test_whenCreatingBoardWithTooManyRows_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3],
                [1, 2, 3]
            ])
        }
        XCTAssertEqual(error, .incorrectNumberOfRows(10))
    }

    func test_whenCreatingBoardWithTooFewColumns_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                []
            ])
        }
        XCTAssertEqual(error, .incorrectNumberOfColumns(3, row: 0))
    }

    func test_whenCreatingBoardWithTooManyColumns_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3, 4, 5, 6, 7, 8, 9, nil],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                []
            ])
        }
        XCTAssertEqual(error, .incorrectNumberOfColumns(10, row: 0))
    }

    func test_whenCreatingBoardWithCorrectRowsButIncorrectColumn_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [],
                [],
                [],
                [],
                [],
                [],
                [],
                []
            ])
        }
        XCTAssertEqual(error, .incorrectNumberOfColumns(0, row: 1))
    }

    func test_whenCreatingBoardWithDuplicateValuesInRow_thenInitializationThrows() throws {
        let error: DuplicateValueError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 1, 1, 1, 1, 1, 1, 1, 1],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9]
            ])
        }
        XCTAssertEqual(error.value, 1)
        XCTAssertEqual(error.segment, .row(3))
    }

    func test_whenCreatingBoardWithDuplicateValuesInColumn_thenInitializationThrows() throws {
        let error: DuplicateValueError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9],
                [1, 2, 3, 4, 5, 6, 7, 8, 9]
            ])
        }
        XCTAssertEqual(error.value, 1)
        XCTAssertEqual(error.segment, .column(0))
    }

    func test_whenCreatingBoardWithDuplicateValuesInRegion_thenInitializationThrows() throws {
        let error: DuplicateValueError = try expectToThrow {
            _ = try RegularSudokuBoard([
                [nil, nil, nil, 1, 2, 3, nil, nil, nil],
                [nil, nil, nil, 4, 1, 6, nil, nil, nil],
                [nil, nil, nil, 7, 8, 9, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil, nil]
            ])
        }
        XCTAssertEqual(error.value, 1)
        XCTAssertEqual(error.segment, .region(1))
    }

    func test_whenCreatingValidEmptyBoard_thenInitializationSucceeds() throws {
        XCTAssertNoThrow(try RegularSudokuBoard([
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil]
        ]))
    }

    func test_whenCreatingValidPartialBoard_thenPartialInitializationSucceeds() throws {
        XCTAssertNoThrow(try RegularSudokuBoard(partiallyComplete: [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]))
    }

    func test_whenCreatingValidPartialBoard_thenInitializationSucceeds() throws {
        XCTAssertNoThrow(try RegularSudokuBoard([
            [1, 2, 3, nil, nil, nil, nil, nil, nil],
            [4, 5, 6, nil, nil, nil, nil, nil, nil],
            [7, 8, 9, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil, nil, nil, nil]
        ]))
    }

    func test_whenCreatingValidFullBoard_thenInitializationSucceeds() throws {
        XCTAssertNoThrow(try RegularSudokuBoard([
            [1, 2, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 9, 1, 2, 3, 4, 5, 6],
            [2, 3, 4, 5, 6, 7, 8, 9, 1],
            [5, 6, 7, 8, 9, 1, 2, 3, 4],
            [8, 9, 1, 2, 3, 4, 5, 6, 7],
            [3, 4, 5, 6, 7, 8, 9, 1, 2],
            [6, 7, 8, 9, 1, 2, 3, 4, 5],
            [9, 1, 2, 3, 4, 5, 6, 7, 8]
        ]))
    }

    private func expectToThrow<E: Error>(block: () throws -> Void) throws -> E {
        do {
            try block()
            throw "Expected to throw Error"
        } catch let error as E {
            return error
        } catch {
            throw "Expected to throw \(E.self)"
        }
    }
}

