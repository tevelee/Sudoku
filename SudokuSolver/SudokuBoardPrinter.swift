import Foundation

public final class SudokuBoardPrinter {
    func print<T: CustomStringConvertible>(_ board: SudokuBoard<T>) -> String {
        var rowsToPrint: [String] = []
        for (rowIndex, values) in board.rawData.enumerated() {
            if rowIndex != 0, rowIndex.isMultiple(of: 3) {
                rowsToPrint.append("- - - + - - - + - - -")
            }
            let row = values.enumerated().flatMap { columnIndex, value in
                let valueString = value.map(String.init) ?? " "
                if columnIndex != 0, columnIndex.isMultiple(of: 3) {
                    return ["|"] + [valueString]
                } else {
                    return [valueString]
                }
            }
            rowsToPrint.append(row.joined(separator: " "))
        }
        return rowsToPrint.joined(separator: "\n")
    }
}
