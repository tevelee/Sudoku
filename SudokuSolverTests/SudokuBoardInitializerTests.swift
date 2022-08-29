import XCTest
@testable import SudokuSolver

final class RegularBoardInitializerTests: XCTestCase {
    func test_whenCreatingBoardWithEmptyColumns_thenInitializationThrows() throws {
        let error: IncorrectSizeError = try expectToThrow {
            _ = try SudokuBoard<Int>([])
        }
        XCTAssertEqual(error, .mustHavePositiveSize)
    }

    func test_whenCreatingValidBoardsWithExplicitSize_thenInitializationSucceeds() throws {
        _ = try SudokuBoard<Int>(width: 1, height: 1, slicing: RegularSudokuSlicing(allowStripes: true))
        _ = try SudokuBoard<Int>(width: 2, height: 2, slicing: RegularSudokuSlicing(allowStripes: true))
        _ = try SudokuBoard<Int>(width: 3, height: 3, slicing: RegularSudokuSlicing(allowStripes: true))
        _ = try SudokuBoard<Int>(width: 2, height: 3, slicing: RegularSudokuSlicing(allowStripes: true))
        _ = try SudokuBoard<Int>(width: 5, height: 5, slicing: RegularSudokuSlicing(allowStripes: true))

        _ = try SudokuBoard<Int>()
        _ = try SudokuBoard<Int>(width: 4, height: 4)
        _ = try SudokuBoard<Int>(width: 4, height: 6)
        _ = try SudokuBoard<Int>(width: 6, height: 6)
        _ = try SudokuBoard<Int>(width: 8, height: 8)
    }

    func test_whenCreatingInvalidBoardsWithExplicitSize_thenInitializationThrows() throws {
        var error: SlicingError = try expectToThrow {
            _ = try SudokuBoard<Int>(width: 1, height: 1)
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)

        error = try expectToThrow {
            _ = try SudokuBoard<Int>(width: 2, height: 2)
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)

        error = try expectToThrow {
            _ = try SudokuBoard<Int>(width: 3, height: 3)
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)

        error = try expectToThrow {
            _ = try SudokuBoard<Int>(width: 2, height: 3)
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)

        error = try expectToThrow {
            _ = try SudokuBoard<Int>(width: 5, height: 5)
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)
    }

    func test_whenCreatingBoardWithTooFewRows_thenInitializationThrows() throws {
        let error: SlicingError = try expectToThrow {
            _ = try SudokuBoard<Int>([
                [1, 2, 3]
            ])
        }
        XCTAssertEqual(error, .mustBeDivisibleToRegions)
    }

    func test_whenCreatingValidEmptyBoard_thenInitializationSucceeds() throws {
        XCTAssertNoThrow(try SudokuBoard<Int>([
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
        XCTAssertNoThrow(try SudokuBoard<Int>(partiallyComplete: [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9]
        ]))
    }

    func test_whenCreatingValidPartialBoard_thenInitializationSucceeds() throws {
        XCTAssertNoThrow(try SudokuBoard<Int>([
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
        XCTAssertNoThrow(try SudokuBoard<Int>([
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

