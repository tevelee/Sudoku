import Foundation

protocol SudokuSolvingStrategy<Value> {
    associatedtype Value: CustomStringConvertible
    func nextMove(on board: SudokuBoard<Value>) -> Move<Value>?
}

public struct Move<Value> {
    let reason: String
    let details: String
    let value: Value
    let position: Position
}

extension Move: Equatable where Value: Equatable {}

extension Array where Element: CustomStringConvertible {
    func list() -> String {
        ListFormatter().string(from: self) ?? map(\.description).joined(separator: ", ")
    }
}
