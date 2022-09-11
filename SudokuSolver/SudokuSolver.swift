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
            OneMissingSymbolStrategy(rules: rules),
            LastRemainingCellStrategy(rules: rules),
            LastPossibleSymbolStrategy(rules: rules),
            EliminatePairsStrategy(rules: rules) { reservedFields in
                [
                    OneMissingSymbolStrategy(rules: rules, reservedFields: reservedFields),
                    LastPossibleSymbolStrategy(rules: rules, reservedFields: reservedFields)
                ]
            }
        ] + strategies
    }

    public func availableMoves(_ board: SudokuBoard<Value>) -> AsyncStream<Move<Value>> {
        strategies.map { $0.moves(on: board, cache: Cache(board)) }.merged()
    }

    public func iterativeSolve(_ board: SudokuBoard<Value>) async -> IterativeSolutionResult<Solution<Value>> {
        await solve(board, moves: [], cache: Cache(board)).map { $0[0] }
    }

    private func solve(_ board: SudokuBoard<Value>,
                       moves: [Move<Value>],
                       cache: Cache<SudokuBoard<Value>>) async -> IterativeSolutionResult<[Solution<Value>]> {
        let newCache = Cache(board)
        newCache.slicedGrid = cache.slicedGrid // reuse existing computations for grid
        return await _solve(board, moves: moves, cache: newCache)
    }

    private func _solve(_ board: SudokuBoard<Value>,
                        moves: [Move<Value>],
                        cache: Cache<SudokuBoard<Value>>) async -> IterativeSolutionResult<[Solution<Value>]> {
        guard isValid(board, cache: cache.slicedGrid) else {
            return .unsolvable
        }
        if board.isCompleted {
            return .solvable([Solution(moves: moves)])
        }
        for strategy in strategies {
            if let move = await strategy.nextMove(on: board, cache: cache) {
                precondition(board[move.position] == nil)
                var newBoard = board
                newBoard[move.position] = move.value
                if case .solvable(let solutions) = await solve(newBoard, moves: moves + [move], cache: cache) {
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

    lazy var allSymbols: [Value] = {
        for rule in rules {
            if let contentRule = isContentRule(rule) {
                return contentRule.allowedSymbols
            }
        }
        return []
    }()

    private func isContentRule(_ value: some SudokuRule<Value>) -> ContentRule<Value>? {
        value as? ContentRule<Value>
    }

    public func quickSolve(_ board: SudokuBoard<Value>) async -> QuickSolutionResult<Value> {
        await solutions(board).first.map(QuickSolutionResult.solvable) ?? .unsolvable
    }

    func hasOnlyOneSolution(_ board: SudokuBoard<Value>) async -> Bool {
        var count = 0
        for await _ in solutions(board) {
            count += 1
            if count > 1 {
                return false
            }
        }
        return count == 1
    }

    func solutions(_ board: SudokuBoard<Value>) -> AsyncStream<SudokuBoard<Value>> {
        AsyncStream<SudokuBoard<Value>> { continuation in
            let task = Task {
                await _solutions(board, cache: Cache(board.slicedGrid)) { solution in
                    continuation.yield(solution)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func _solutions(_ board: SudokuBoard<Value>, cache: Cache<SlicedGrid>, block: (SudokuBoard<Value>) -> Void) async {
        guard !Task.isCancelled, isValid(board, cache: cache) else {
            return
        }

        if board.isCompleted {
            block(board)
            return
        }

        if let position = board.incompletePositions.first {
            for value in allSymbols {
                await Task.yield()
                var newBoard = board
                newBoard[position] = value
                await _solutions(newBoard, cache: cache, block: block)
            }
        }
    }

    func isValid(_ board: SudokuBoard<Value>, cache: Cache<SlicedGrid>) -> Bool {
        let slices = cache.grid.rows() + cache.grid.columns() + cache.regions()
        let sliceItems = slices.map { $0.items.lazy.map(board.value) }
        return rules.reversed().allSatisfy { rule in
            sliceItems.allSatisfy(rule.isValid)
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
    case unsolvable
}

extension QuickSolutionResult: Equatable where Value: Equatable {}

public struct Solution<Value> {
    public let moves: [Move<Value>]
}

extension Solution: Equatable where Value: Equatable {}
