import Foundation

public final class RegularBoardSolver {
    public init() {}

    public func solve(_ board: RegularSudokuBoard) -> Solution {
        if board.rows.allSatisfy({ !$0.contains(nil) }) {
            return .solvable(solutions: [board])
        }
        return .couldNotSolve
    }
}

public enum Solution: Equatable {
    case solvable(solutions: [RegularSudokuBoard])
    case unsolvable
    case couldNotSolve
}
