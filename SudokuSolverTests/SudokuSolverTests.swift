import XCTest
import SudokuSolver

final class SudokuTests: XCTestCase {
    func test_whenCreatingInvalidBoard_thenInitializationThrows() throws {
        XCTAssertThrowsError(try SudokuBoard([
            [1, 2, 3],
            [1, 2, 3],
            [1, 2, 3]
        ]))
    }
}
