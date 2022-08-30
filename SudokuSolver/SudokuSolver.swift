import Foundation

@available(macOS 13.0.0, *)
public final class SudokuSolver<Value: Hashable & CustomStringConvertible> {
    private let rules: [any SudokuRule<Value>]
    private let strategies: [any SudokuSolvingStrategy<Value>]

    public init(rules: [any SudokuRule<Value>] = []) {
        self.rules = rules
        strategies = [
            OneMissingSymbolStrategy<Value>(rules: rules),
            LastRemainingCellStrategy<Value>(rules: rules),
            LastPossibleSymbolStrategy<Value>(rules: rules)
        ]
    }

    public func iterativeSolve(_ board: SudokuBoard<Value>) -> IterativeSolutionResult<Solution<Value>> {
        solve(board, moves: [], findFirstSolutionOnly: true).map { $0[0] }
    }

    public func availableMoves(_ board: SudokuBoard<Value>) -> [Move<Value>] {
        let cache = Cache(board: board)
        return strategies.compactMap { $0.nextMove(on: board, cache: cache) }
    }

    private func solve(_ board: SudokuBoard<Value>,
                       moves: [Move<Value>],
                       findFirstSolutionOnly: Bool = true) -> IterativeSolutionResult<[Solution<Value>]> {
        guard board.isValid(against: rules) else {
            return .unsolvable
        }
        if board.isCompleted {
            return .solvable([Solution(moves: moves)])
        }
        var result: [Solution<Value>] = []
        let cache = Cache(board: board)
        for strategy in strategies {
            if let move = strategy.nextMove(on: board, cache: cache) {
                var newBoard = board
                newBoard[move.position] = move.value
                if case .solvable(let solutions) = solve(newBoard, moves: moves + [move]) {
                    result.append(contentsOf: solutions)
                    if findFirstSolutionOnly {
                        return .solvable(result)
                    }
                }
            }
        }
        return result.isEmpty ? .couldNotSolve : .solvable(result)
    }
}

extension SudokuBoard {
    var isCompleted: Bool {
        values.allSatisfy { $0 != nil }
    }

    func isValid(against rules: [any SudokuRule<Value>]) -> Bool {
        guard rows.isValid(against: rules),
              columns.isValid(against: rules),
              regions.isValid(against: rules) else {
            return false
        }
        return true
    }
}

@available(macOS 13.0.0, *)
extension SudokuSolver where Value: Equatable {
    public func quickSolve(_ board: SudokuBoard<Value>) -> QuickSolutionResult<Value> {
        guard let contentRule = self.contentRule() else {
            return .noContentRuleToPickElementsFrom
        }
        return quickSolve(board, contentRule: contentRule)
    }

    private func quickSolve(_ board: SudokuBoard<Value>, contentRule: ContentRule<Value>) -> QuickSolutionResult<Value> {
        guard board.rows.isValid(against: rules),
              board.columns.isValid(against: rules),
              board.regions.isValid(against: rules) else {
            return .unsolvable
        }

        if board.values.allSatisfy({ $0 != nil }) {
            return .solvable(board)
        }

        if let position = board.firstIncompletePosition() {
            for value in contentRule.allowedSymbols {
                var board = board
                board[position] = value
                if case .solvable(let board) = quickSolve(board, contentRule: contentRule) {
                    return .solvable(board)
                }
            }
        }
        return .unsolvable
    }

    private func contentRule() -> ContentRule<Value>? {
        for rule in rules {
            if let contentRule = isContentRule(rule) {
                return contentRule
            }
        }
        return nil
    }

    private func isContentRule(_ value: some SudokuRule<Value>) -> ContentRule<Value>? {
        value as? ContentRule<Value>
    }
}

private extension Sequence {
    @available(macOS 13.0.0, *)
    func isValid<Wrapped>(against rules: [any SudokuRule<Wrapped>]) -> Bool where Element == Slice<(position: Position, value: Wrapped?)> {
        allSatisfy { slice in
            rules.allSatisfy { $0.isValid(slice) }
        }
    }
}

public enum IterativeSolutionResult<Solution> {
    case solvable(Solution)
    case unsolvable
    case couldNotSolve

    func map<K>(_ transform: (Solution) -> K) -> IterativeSolutionResult<K> {
        switch self {
            case .solvable(let solution):
                return .solvable(transform(solution))
            case .unsolvable:
                return .unsolvable
            case .couldNotSolve:
                return .couldNotSolve
        }
    }
}

extension IterativeSolutionResult: Equatable where Solution: Equatable {}

public enum QuickSolutionResult<Value> {
    case solvable(SudokuBoard<Value>)
    case noContentRuleToPickElementsFrom
    case unsolvable
}

extension QuickSolutionResult: Equatable where Value: Equatable {}

public struct Solution<Value> {
    public let moves: [Move<Value>]
}

extension Solution: Equatable where Value: Equatable {}
