import Foundation

@available(macOS 13.0.0, *)
public final class SudokuSolver<Value: Hashable & CustomStringConvertible> {
    private let rules: [any SudokuRule<Value>]
    private let strategies: [any SudokuSolvingStrategy<Value>]

    public init(rules: [any SudokuRule<Value>] = []) {
        self.rules = rules
        strategies = [
            OneMissingElementStrategy<Value>(rules: rules)
        ]
    }

    public func iterativeSolve(_ board: SudokuBoard<Value>) -> IterativeSolutionResult<Value> {
        solve(board, moves: [])
    }

    private func solve(_ board: SudokuBoard<Value>, moves: [Move<Value>]) -> IterativeSolutionResult<Value> {
        guard board.isValid(against: rules) else {
            return .unsolvable
        }
        if board.isCompleted {
            return .solvable(solutions: [Solution(moves: moves)])
        }
        var result: [Solution<Value>] = []
        for strategy in strategies {
            if let move = strategy.nextMove(on: board) {
                var newBoard = board
                newBoard[move.position] = move.value
                if case .solvable(let solutions) = solve(newBoard, moves: moves + [move]) {
                    result.append(contentsOf: solutions)
                }
            }
        }
        return result.isEmpty ? .couldNotSolve : .solvable(solutions: result)
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

protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible
    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>?
}

public struct Move<Value> {
    let reason: String
    let value: Value
    let position: Position
}

extension Move: Equatable where Value: Equatable {}

final class OneMissingElementStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>? {
        nextMove(for: board.rows) ?? nextMove(for: board.columns) ?? nextMove(for: board.regions)
    }

    private func nextMove(for slices: some Sequence<BoardSlice<Value>>) -> Move<Value>? {
        for slice in slices {
            let items = Set(slice.items.compactMap(\.value))
            if items.count == symbols.count - 1,
               let emptyPosition = slice.items.first(where: { $0.value == nil })?.position,
               let missingValue = symbols.subtracting(items).first {
                return Move(reason: "\(missingValue) is the only symbol missing from \(slice.name)", value: missingValue, position: emptyPosition)
            }
        }
        return nil
    }

    private lazy var symbols = contentRule().map { Set($0.allowedSymbols) } ?? []

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

public enum IterativeSolutionResult<Value> {
    case solvable(solutions: [Solution<Value>])
    case unsolvable
    case couldNotSolve
}

extension IterativeSolutionResult: Equatable where Value: Equatable {}

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
