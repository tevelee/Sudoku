public final class SudokuBoardGenerator<Value> {
    public init() {}

    public func generate(width: Int = 9,
                         height: Int = 9,
                         slicing: SlicingStrategy = RegularSudokuSlicing()) -> AsyncStream<SudokuBoard<Value>> {
        .init { continuation in
            if let board = try? SudokuBoard<Value>(width: width, height: height, slicing: slicing) {
                continuation.yield(board)
            }
            continuation.finish()
        }
    }
}
