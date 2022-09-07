extension Cache {
    func rows() -> [GridSlice] where Subject == Grid {
        self[RowsCache.self]
    }

    func rows<T>() -> [GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.rows()
    }
}

private struct RowsCache: CachedComputation {
    static func compute(_ cache: Cache<Grid>) -> [GridSlice] {
        Array(Rows(grid: cache.subject))
    }
}
