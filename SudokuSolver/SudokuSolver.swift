import Foundation

public final class SudokuSolver {
    public init() {}

    public func iterativeSolve(_ board: SudokuBoard<Int>) -> IterativeSolutionResult {
        if board.values.allSatisfy({ $0 != nil }) {
            return .solvable(solutions: [.init(steps: [])])
        }
        return .couldNotSolve
    }

    public func quickSolve(_ board: SudokuBoard<Int>) -> QuickSolutionResult {
//        let validator = BoardValidator(rows: board.rawData)
//        do {
//            try validator.validateDuplicateValuesInRows()
//            try validator.validateDuplicateValuesInColumns()
//            try validator.validateDuplicateValuesInRegions()
//        } catch {
//            return .unsolvable
//        }
//
//        if board.values.allSatisfy({ $0 != nil }) {
//            return .solvable(board)
//        }
//
//        let values = Array(1 ... 9)
//        if let position = board.firstIncompletePosition() {
//            for value in values {
//                var board = board
//                board[position] = value
//                if case .solvable(let board) = quickSolve(board) {
//                    return .solvable(board)
//                }
//            }
//        }
        return .unsolvable
    }
}

public enum IterativeSolutionResult: Equatable {
    case solvable(solutions: [Solution])
    case unsolvable
    case couldNotSolve
}

public enum QuickSolutionResult: Equatable {
    case solvable(SudokuBoard<Int>)
    case unsolvable
}

public struct Solution: Equatable {
    public let steps: [SudokuBoard<Int>]
}

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
