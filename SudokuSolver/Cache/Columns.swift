extension Cache {
    func columns() -> [GridSlice] where Subject == Grid {
        self[ColumnsCache.self]
    }

    func columns<T>() -> [GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.columns()
    }
}

private struct ColumnsCache: CachedComputation {
    static func compute(_ cache: Cache<Grid>) -> [GridSlice] {
        Array(Columns(grid: cache.subject))
    }
}
