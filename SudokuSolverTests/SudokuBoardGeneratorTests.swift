import XCTest
@testable import SudokuSolver

@available(macOS 13.0.0, *)
final class RegularBoardGeneratorTests: XCTestCase {
    func test_whenGeneratingBoards_thenGivesValidBoard() async {
        // Given
        let generator = SudokuBoardGenerator<Int>()

        // When
//        let board = await generator.generateFullBoard(deterministic: true)
        let board = await generator.generateSolvablePuzzle(difficulty: .advanced)

        // Then
        XCTAssertEqual(board, try? SudokuBoard([
            [1, 2, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 9, 1, 2, 3, 4, 5, 6],
            [2, 1, 4, 3, 6, 5, 8, 9, 7],
            [3, 6, 5, 8, 9, 7, 2, 1, 4],
            [8, 9, 7, 2, 1, 4, 3, 6, 5],
            [5, 3, 1, 6, 4, 2, 9, 7, 8],
            [6, 4, 2, 9, 7, 8, 5, 3, 1],
            [9, 7, 8, 5, 3, 1, 6, 4, 2]
        ]))
    }
}
