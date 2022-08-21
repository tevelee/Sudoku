import Foundation

public final class RegularBoardSolver {
    public init() {}

    public func iterativeSolve(_ board: RegularSudokuBoard) -> IterativeSolutionResult {
        if board.rows.allSatisfy({ !$0.contains(nil) }) {
            return .solvable(solutions: [.init(steps: [])])
        }
        return .unsolvable
    }

    public func quickSolve(_ board: RegularSudokuBoard) -> QuickSolutionResult {
        let validator = BoardValidator(rows: board.rows)
        do {
            try validator.validateDuplicateValuesInRows()
            try validator.validateDuplicateValuesInColumns()
            try validator.validateDuplicateValuesInRegions()
        } catch {
            return .unsolvable
        }

        if board.rows.allSatisfy({ !$0.contains(nil) }) {
            return .solvable(board)
        }

        let values = Array(1 ... 9)
        if let position = board.firstIncompletePosition() {
            for value in values {
                var board = board
                board[position] = value
                if case .solvable(let board) = quickSolve(board) {
                    return .solvable(board)
                }
            }
        }
        return .unsolvable
    }
}

public enum IterativeSolutionResult: Equatable {
    case solvable(solutions: [Solution])
    case unsolvable
}

public enum QuickSolutionResult: Equatable {
    case solvable(RegularSudokuBoard)
    case unsolvable
}

public struct Solution: Equatable {
    public let steps: [RegularSudokuBoard]
}
