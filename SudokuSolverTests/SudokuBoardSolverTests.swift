import XCTest
@testable import SudokuSolver

@available(macOS 13.0.0, *)
final class RegularBoardSolverTests: XCTestCase {
    func test_whenAttemptingToSolveEmptyBoard_thenGivesAllSolutions() {
        // TODO: empty board shows all solutions
    }

    func test_whenAttemptingToSolveFullBoard_thenGivesExistingSolution() {
        // Given
        let board = try! SudokuBoard<Int>([
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
        let contentRule = ContentRule(allowedSymbols: 1...9)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let solver = SudokuSolver(rules: [contentRule, uniquenessRule])

        // When
        let solutions = solver.iterativeSolve(board)

        // Then
        XCTAssertEqual(solutions, .solvable(solutions: [.init(moves: [])]))
    }

    func test_whenAttemptingToSolveBoardWithOneMissingValue_thenFindsMissingValue() {
        // Given
        let board = try! SudokuBoard<Int>([
            [1, nil, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 9, 1, 2, 3, 4, 5, 6],
            [2, 3, 4, 5, 6, 7, 8, 9, 1],
            [5, 6, 7, 8, 9, 1, 2, 3, 4],
            [8, 9, 1, 2, 3, 4, 5, 6, 7],
            [3, 4, 5, 6, 7, 8, 9, 1, 2],
            [6, 7, 8, 9, 1, 2, 3, 4, 5],
            [9, 1, 2, 3, 4, 5, 6, 7, 8]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...9)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let solver = SudokuSolver(rules: [contentRule, uniquenessRule])

        // When
        let solutions = solver.iterativeSolve(board)

        // Then
        XCTAssertEqual(solutions, .solvable(solutions: [.init(moves: [
            Move(reason: "2 is the only symbol missing from Row 1", value: 2, position: Position(row: 0, column: 1))
        ])]))
    }

    func test_whenAttemptingToQuickSolveBoard_thenProvidesSolution() {
        // Given
        let board = try! SudokuBoard<Int>(partiallyComplete: [])
        let contentRule = ContentRule(allowedSymbols: 1...9)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let solver = SudokuSolver(rules: [contentRule, uniquenessRule])

        // When
        let solution = solver.quickSolve(board)

        // Then
        XCTAssertEqual(solution, .solvable(try! SudokuBoard([
            [1, 2, 3, 4, 5, 6, 7, 8, 9],
            [4, 5, 6, 7, 8, 9, 1, 2, 3],
            [7, 8, 9, 1, 2, 3, 4, 5, 6],
            [2, 1, 4, 3, 6, 5, 8, 9, 7],
            [3, 6, 5, 8, 9, 7, 2, 1, 4],
            [8, 9, 7, 2, 1, 4, 3, 6, 5],
            [5, 3, 1, 6, 4, 2, 9, 7, 8],
            [6, 4, 2, 9, 7, 8, 5, 3, 1],
            [9, 7, 8, 5, 3, 1, 6, 4, 2]
        ])))
    }
}

