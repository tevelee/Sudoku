import XCTest
@testable import SudokuSolver

@available(macOS 13.0.0, *)
final class RegularBoardSolverTests: XCTestCase {
    func test_whenAttemptingToSolveEmptyBoard_thenGivesAllSolutions() {
        // TODO: empty board shows all solutions
    }

    func test_whenAttemptingToSolveFullBoard_thenGivesExistingSolution() async {
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
        let solutions = await solver.iterativeSolve(board)

        // Then
        XCTAssertEqual(solutions, .solvable(Solution(moves: [])))
    }

    func test_whenAttemptingToSolveBoardWithOneMissingValue_thenFindsMissingValue() async {
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
        let solutions = await solver.iterativeSolve(board)

        // Then
        XCTAssertEqual(solutions, .solvable(Solution(moves: [
            Move(reason: "2 is the only symbol missing from Row 1",
                 details: "Row 1 already contains 8 out of 9 values: 1, 3, 4, 5, 6, 7, 8, and 9",
                 value: 2,
                 position: Position(row: 0, column: 1))
        ])))
    }

    func test_whenAttemptingToSolveRealBoard_thenFindsSolution() async {
        // Given
        let board = try! SudokuBoard<Int>([
            [  3,   4,   2,        nil,   8, nil,       nil, nil, nil],
            [  5, nil, nil,          9, nil, nil,       nil, nil, nil],
            [nil,   9, nil,        nil, nil,   4,         3,   8, nil],

            [nil,   2, nil,          3, nil,   5,         1, nil, nil],
            [nil,   5, nil,          7, nil,   6,       nil,   4, nil],
            [nil,   7, nil,        nil,   9,   1,         6,   5,   2],

            [  6, nil, nil,        nil,   7,   9,         2,   3,   1],
            [  7, nil, nil,        nil,   6, nil,         8, nil, nil],
            [  2, nil, nil,          5,   3, nil,         4, nil, nil],
        ])
        let contentRule = ContentRule(allowedSymbols: 1...9)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let solver = SudokuSolver(rules: [contentRule, uniquenessRule])

        // When
        let solutions = await solver.iterativeSolve(board)

        // Then
        for await move in solver.availableMoves(board) {
            print(move)
        }
        if case .solvable(let solution) = solutions {
            print(solution)
        }
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

