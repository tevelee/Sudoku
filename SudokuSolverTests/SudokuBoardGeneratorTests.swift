import XCTest
@testable import SudokuSolver

@available(macOS 13.0.0, *)
final class RegularBoardGeneratorTests: XCTestCase {
    func test_whenGeneratingBoards_thenGivesValidBoard() async {
        // Given
        let solver = SudokuSolver(rules: [
            ContentRule(allowedSymbols: 1...9),
            UniqueSymbolsRule()
        ])
        let generator = SudokuBoardGenerator<Int>()

        // When
        let board = await generator.generate().first

        // Then
        XCTAssertEqual(board, try? SudokuBoard([
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
}
