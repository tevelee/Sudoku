extension Cache {
    func covers<Value>() -> [Position: CoveredValue<Value>] where Subject == SudokuBoard<Value> {
        self[CoversCache<Value>.self]
    }
}

private struct CoversCache<T: Hashable>: CachedComputation {
    static func compute(_ cache: Cache<SudokuBoard<T>>) -> [Position: CoveredValue<T>] {
        let board = cache.subject
        var result: [Position: CoveredValue<T>] = [:]
        for row in cache.rows() {
            for position in row.items {
                if let value = board[position] {
                    result[position] = .done(value)
                } else {
                    let row = Set(cache.row(for: position)?.compactMap(board.value).items ?? [])
                    let column = Set(cache.column(for: position)?.compactMap(board.value).items ?? [])
                    let region = Set(cache.region(for: position)?.compactMap(board.value).items ?? [])
                    result[position] = .incomplete(Covers(row: row, column: column, region: region))
                }
            }
        }
        return result
    }
}
