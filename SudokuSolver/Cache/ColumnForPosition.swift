extension Cache {
    func columnForPosition() -> [Position: GridSlice] where Subject == Grid {
        self[ColumnForPosition.self]
    }

    func columnForPosition<T>() -> [Position: GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.columnForPosition()
    }

    func column<T>(for position: Position) -> GridSlice? where Subject == SudokuBoard<T> {
        columnForPosition()[position]
    }
}

private struct ColumnForPosition: CachedComputation {
    static func compute(_ cache: Cache<Grid>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in cache.columns() {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}
