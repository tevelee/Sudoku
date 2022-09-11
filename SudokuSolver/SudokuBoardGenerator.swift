public final class SudokuBoardGenerator<Value: Hashable & CustomStringConvertible> {
    private let deterministic: Bool
    private let solver: SudokuSolver<Value>

    public init(deterministic: Bool = false,
                solver: SudokuSolver<Value> = SudokuSolver(rules: [
                    ContentRule(allowedSymbols: 1...9),
                    UniqueSymbolsRule()
                ])) {
        self.deterministic = deterministic
        self.solver = solver
    }

    public enum Difficulty: Comparable {
        case beginner
        case easy
        case medium
        case advanced
        case hard

        func numberOfGivenPositions(for size: Size) -> Int {
            let min = size.width + size.height
            let max = size.width * size.height
            return Int(Double(min) + Double(max - min) * (1.0 - percentage))
        }

        var percentage: Double {
            switch self {
                case .beginner: return 0
                case .easy: return 0.25
                case .medium: return 0.5
                case .advanced: return 0.75
                case .hard:  return 1
            }
        }
    }

    public func generateSolvablePuzzle(difficulty: Difficulty = .medium,
                                       filterOnlySingleSolutions: Bool = true,
                                       symmetric: Bool = true,
                                       fromPartial board: SudokuBoard<Value> = try! SudokuBoard<Int>()) async -> SudokuBoard<Value>? {
        guard var board = await generateFullBoard(fromPartial: board) else {
            return nil
        }
        let numberOfPositions = difficulty.numberOfGivenPositions(for: board.slicedGrid.grid.size)
        while board.completePositions.count > numberOfPositions {
            for position in deterministic ? board.completePositions : board.completePositions.shuffled() {
                var newBoard = board
                newBoard[position] = nil
                if symmetric {
                    newBoard[newBoard.opposite(position)] = nil
                }
                if !filterOnlySingleSolutions {
                    board = newBoard
                    break
                } else if await solver.hasOnlyOneSolution(newBoard) {
                    board = newBoard
                    break
                }
            }
        }
        return board
    }

    func generateFullBoard(fromPartial board: SudokuBoard<Value> = try! SudokuBoard<Int>()) async -> SudokuBoard<Value>? {
        guard solver.isValid(board, cache: Cache(board.slicedGrid)) else {
            return nil
        }
        guard let position = board.incompletePositions.first else {
            return board
        }

        for value in deterministic ? solver.allSymbols : solver.allSymbols.shuffled() {
            await Task.yield()
            var newBoard = board
            newBoard[position] = value
            if let board = await generateFullBoard(fromPartial: newBoard) {
                return board
            }
        }
        return nil
    }
}

