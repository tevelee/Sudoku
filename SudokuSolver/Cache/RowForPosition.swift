extension Cache {
    func rowForPosition() -> [Position: GridSlice] where Subject == Grid {
        self[RowForPosition.self]
    }

    func rowForPosition<T>() -> [Position: GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.rowForPosition()
    }

    func row<T>(for position: Position) -> GridSlice? where Subject == SudokuBoard<T> {
        rowForPosition()[position]
    }
}

private struct RowForPosition: CachedComputation {
    static func compute(_ cache: Cache<Grid>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in cache.rows() {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}
