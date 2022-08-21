import Foundation

public struct SudokuBoard: Hashable {
    public init(_ values: [[Int]]) throws {
        throw InvalidBoard()
    }
}

public struct InvalidBoard: Error {}
