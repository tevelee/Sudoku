public final class SudokuBoardGenerator<Value: Hashable & CustomStringConvertible> {
    public init() {}

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
                                       symmetric: Bool = true,
                                       deterministic: Bool = false,
                                       solver: SudokuSolver<Value> = SudokuSolver(rules: [
                                          ContentRule(allowedSymbols: 1...9),
                                          UniqueSymbolsRule()
                                       ]),
                                       fromPartial board: SudokuBoard<Value> = try! SudokuBoard<Int>()) async -> SudokuBoard<Value>? {
        guard var board = await self.generateFullBoard(solver: solver, fromPartial: board, deterministic: deterministic) else {
            return nil
        }
        while board.completePositions.count > difficulty.numberOfGivenPositions(for: board.slicedGrid.grid.size) {
            for position in deterministic ? board.completePositions : board.completePositions.shuffled() {
                var newBoard = board
                newBoard[position] = nil
                if symmetric {
                    newBoard[newBoard.opposite(position)] = nil
                }
                if await solver.hasOnlyOneSolution(newBoard) {
                    board = newBoard
                    break
                }
            }
        }
        return board
    }

    func generateFullBoard(solver: SudokuSolver<Value> = SudokuSolver(rules: [
                               ContentRule(allowedSymbols: 1...9),
                               UniqueSymbolsRule()
                           ]),
                           fromPartial board: SudokuBoard<Value> = try! SudokuBoard<Int>(),
                           deterministic: Bool = false) async -> SudokuBoard<Value>? {
        await Task.yield()

        guard solver.isValid(board) else {
            return nil
        }

        if board.values.allSatisfy({ $0 != nil }) {
            return board
        }

        if let position = board.incompletePositions.first {
            for value in deterministic ? solver.allSymbols : solver.allSymbols.shuffled() {
                var newBoard = board
                newBoard[position] = value
                if let board = await generateFullBoard(solver: solver, fromPartial: newBoard, deterministic: deterministic) {
                    return board
                }
            }
        }
        return nil
    }
}

