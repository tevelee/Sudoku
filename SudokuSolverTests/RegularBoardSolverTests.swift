import XCTest
@testable import SudokuSolver

final class RegularBoardSolverTests: XCTestCase {
    func test_whenAttemptingToSolveEmptyBoard_thenGivesAllSolutions() {
        // TODO: empty board shows all solutions
    }

    func test_whenAttemptingToSolveFullBoard_thenGivesExistingSolution() {
        // Given
        let board = try! RegularSudokuBoard([
            [1, 2, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 9, 1, 2, 3, 4, 5, 6],
            [2, 3, 4, 5, 6, 7, 8, 9, 1],
            [5, 6, 7, 8, 9, 1, 2, 3, 4],
            [8, 9, 1, 2, 3, 4, 5, 6, 7],
            [3, 4, 5, 6, 7, 8, 9, 1, 2],
            [6, 7, 8, 9, 1, 2, 3, 4, 5],
            [9, 1, 2, 3, 4, 5, 6, 7, 8]
        ])
        let solver = RegularBoardSolver()

        // When
        let solutions = solver.solve(board)

        // Then
        XCTAssertEqual(solutions, .solvable(solutions: [board]))
    }
}

