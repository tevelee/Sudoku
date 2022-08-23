import Foundation

@available(macOS 13.0.0, *)
public final class SudokuSolver<Value> {
    private let rules: [any SudokuRule<Value>]

    public init(rules: [any SudokuRule<Value>] = []) {
        self.rules = rules
    }

    public func iterativeSolve(_ board: SudokuBoard<Value>) -> IterativeSolutionResult<Value> {
        if board.values.allSatisfy({ $0 != nil }) {
            return .solvable(solutions: [.init(steps: [])])
        }
        return .couldNotSolve
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
    func isValid<Wrapped>(against rules: [any SudokuRule<Wrapped>]) -> Bool where Element == Slice<Wrapped?> {
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
    public let steps: [SudokuBoard<Value>]
}

extension Solution: Equatable where Value: Equatable {}
