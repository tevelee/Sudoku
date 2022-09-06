import Foundation

@available(macOS 13.0.0, *)
public final class SudokuSolver<Value: Hashable & CustomStringConvertible> {
    private let rules: [any SudokuRule<Value>]
    private let strategies: [any SudokuSolvingStrategy<Value>]

    public init(rules: [any SudokuRule<Value>], strategies: [any SudokuSolvingStrategy<Value>]) {
        self.rules = rules
        self.strategies = strategies
    }

    public init(rules: [any SudokuRule<Value>] = [],
                additionalStrategies strategies: [any SudokuSolvingStrategy<Value>] = []) {
        self.rules = rules
        self.strategies = [
            OneMissingSymbolStrategy<Value>(rules: rules),
            LastRemainingCellStrategy<Value>(rules: rules),
            LastPossibleSymbolStrategy<Value>(rules: rules)
        ] + strategies
    }

    public func availableMoves(_ board: SudokuBoard<Value>) -> AsyncStream<Move<Value>> {
        var layoutCache = Cache(board.slicedGrid)
        var valueCache = Cache(board)
        return strategies.map { $0.moves(on: board, layoutCache: &layoutCache, valueCache: &valueCache) }.merged()
    }

    public func iterativeSolve(_ board: SudokuBoard<Value>) async -> IterativeSolutionResult<Solution<Value>> {
        var layoutCache = Cache(board.slicedGrid)
        return await solve(board, moves: [], layoutCache: &layoutCache).map { $0[0] }
    }

    private func solve(_ board: SudokuBoard<Value>,
                       moves: [Move<Value>],
                       layoutCache: inout Cache<SlicedGrid>) async -> IterativeSolutionResult<[Solution<Value>]> {
        var cache = Cache(board)
        return await solve(board, moves: moves, layoutCache: &layoutCache, valueCache: &cache)
    }

    private func solve(_ board: SudokuBoard<Value>,
                       moves: [Move<Value>],
                       layoutCache: inout Cache<SlicedGrid>,
                       valueCache: inout Cache<SudokuBoard<Value>>) async -> IterativeSolutionResult<[Solution<Value>]> {
        guard valueCache.rows().isValid(against: rules),
              valueCache.columns().isValid(against: rules),
              valueCache.regions().isValid(against: rules) else {
            return .unsolvable
        }
        if board.isCompleted {
            return .solvable([Solution(moves: moves)])
        }
        for strategy in strategies {
            if let move = await strategy.nextMove(on: board, layoutCache: &layoutCache, valueCache: &valueCache) {
                var newBoard = board
                newBoard[move.position] = move.value
                if case .solvable(let solutions) = await solve(newBoard, moves: moves + [move], layoutCache: &layoutCache) {
                    return .solvable(solutions)
                }
            }
        }

        if moves.isEmpty {
            return .couldNotSolve
        } else {
            return .partialSolution([Solution(moves: moves)])
        }
    }
}

extension SudokuBoard {
    var isCompleted: Bool {
        values.allSatisfy { $0 != nil }
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
        var cache = Cache(board)
        guard cache.rows().isValid(against: rules),
              cache.columns().isValid(against: rules),
              cache.regions().isValid(against: rules) else {
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

private extension Array {
    @available(macOS 13.0.0, *)
    func isValid<Wrapped>(against rules: [any SudokuRule<Wrapped>]) -> Bool where Element == BoardSlice<Wrapped?> {
        allSatisfy { slice in
            rules.allSatisfy { rule in
                rule.isValid(slice)
            }
        }
    }
}

public enum IterativeSolutionResult<Solution> {
    case solvable(Solution)
    case unsolvable
    case couldNotSolve
    case partialSolution(Solution)

    func map<K>(_ transform: (Solution) -> K) -> IterativeSolutionResult<K> {
        switch self {
            case .solvable(let solution):
                return .solvable(transform(solution))
            case .unsolvable:
                return .unsolvable
            case .couldNotSolve:
                return .couldNotSolve
            case .partialSolution(let solution):
                return .partialSolution(transform(solution))
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

private extension Array {
    func merged<T>() -> AsyncStream<T> where Element == AsyncStream<T> {
        .init { continuation in
            Task {
                for stream in self {
                    for await item in stream {
                        continuation.yield(item)
                    }
                }
                continuation.finish()
            }
        }
    }
}
