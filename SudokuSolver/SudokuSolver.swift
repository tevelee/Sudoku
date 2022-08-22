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
//        guard board.rows.isValid(against: rules),
//              board.columns.isValid(against: rules),
//              board.regions.isValid(against: rules) else {
//            return .unsolvable
//        }

        if board.values.allSatisfy({ $0 != nil }) {
            return .solvable(board)
        }

        if let contentRule = rules.first(where: { $0 is ContentRule<Value> }) as? ContentRule<Value> {
            if let position = board.firstIncompletePosition() {
                for value in contentRule.allowedSymbols {
                    var board = board
                    board[position] = value
                    if case .solvable(let board) = quickSolve(board) {
                        return .solvable(board)
                    }
                }
            }
        }
        return .unsolvable
    }
}

private extension Division {
    @available(macOS 13.0.0, *)
    func isValid(against rules: [any SudokuRule<T>]) -> Bool {
        slices.allSatisfy { slice in
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
    case unsolvable
}

extension QuickSolutionResult: Equatable where Value: Equatable {}

public struct Solution<Value> {
    public let steps: [SudokuBoard<Value>]
}

extension Solution: Equatable where Value: Equatable {}

//struct BoardValidator {
//    let rows: [[Value]]
//
//    func validateNumberOfRows() throws {
//        let numberOfRows = rows.count
//        guard numberOfRows == 9 else {
//            throw IncorrectSizeError.incorrectNumberOfRows(numberOfRows)
//        }
//    }
//
//    func validateNumberOfColumnsInAllRows() throws {
//        for rowIndex in rows.indices {
//            let numberOfColumns = rows[rowIndex].count
//            guard numberOfColumns == 9 else {
//                throw IncorrectSizeError.incorrectNumberOfColumns(numberOfColumns, row: rowIndex)
//            }
//        }
//    }
//
//    func validateSize() throws {
//        guard !rows.isEmpty, rows.allSatisfy({ !$0.isEmpty }) else {
//            throw IncorrectSizeError.mustHavePositiveSize
//        }
//    }
//
//    func validateValues() throws {
//        let validValues: Set<Value> = [nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
//        for (rowIndex, row) in rows.enumerated() {
//            for (columnIndex, value) in row.enumerated() {
//                if !validValues.contains(value) {
//                    throw IncorrectValueError(value: value, row: rowIndex, column: columnIndex)
//                }
//            }
//        }
//    }
//
//    typealias CountsOfValues = [Value: Count]
//
//    func validateDuplicateValuesInRows() throws {
//        if let duplicate = findDuplicates(in: rows) {
//            throw DuplicateValueError(value: duplicate.value, segment: .row(duplicate.index))
//        }
//    }
//
//    func validateDuplicateValuesInColumns() throws {
//        let columns = (0 ..< 9).map { columnIndex in
//            rows.map { $0[columnIndex] }
//        }
//        if let duplicate = findDuplicates(in: columns) {
//            throw DuplicateValueError(value: duplicate.value, segment: .column(duplicate.index))
//        }
//    }
//
//    func validateDuplicateValuesInRegions() throws {
//        var regions: [[Value]] = []
//        for rowIndex in stride(from: 0, to: 9, by: 3) {
//            for columnIndex in stride(from: 0, to: 9, by: 3) {
//                let region = [0, 1, 2].flatMap { rowOffset in
//                    [0, 1, 2].map { columnOffset in
//                        rows[rowIndex + rowOffset][columnIndex + columnOffset]
//                    }
//                }
//                regions.append(region)
//            }
//        }
//        if let duplicate = findDuplicates(in: regions) {
//            throw DuplicateValueError(value: duplicate.value, segment: .region(duplicate.index))
//        }
//    }
//
//    private func findDuplicates(in values: [[Value]]) -> (value: Value, index: Int)? {
//        var map: [Index: CountsOfValues] = [:]
//        for (index, values) in values.enumerated() {
//            for value in values {
//                guard let value = value else {
//                    continue
//                }
//                let count = map[index]?[value] ?? 0
//                if count == 1 {
//                    return (value, index)
//                }
//                map[index, default: [:]][value] = count + 1
//            }
//        }
//        return nil
//    }
//}
