import Foundation

extension Collection where Element: CustomStringConvertible {
    func formatted(formatter: ListFormatter = .english) -> String {
        map(\.description).sorted().list(formatter: formatter)
    }
}

extension Array where Element: CustomStringConvertible {
    func list(formatter: ListFormatter = .english) -> String {
        formatter.string(from: self) ?? map(\.description).joined(separator: ", ")
    }
}

extension ListFormatter {
    static let english = ListFormatter().apply {
        $0.locale = Locale(identifier: "en-US")
    }
}

func formatted<Value>(position: Position, cache: Cache<SudokuBoard<Value>>) -> String {
    let row = cache.row(for: position)?.name ?? ""
    let column = cache.column(for: position)?.name ?? ""
    return "\(row) \(column)"
}
