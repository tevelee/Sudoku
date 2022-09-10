extension Cache {
    func rows() -> [GridSlice] where Subject == Grid {
        self[RowsCache.self]
    }

    func rows<T>() -> [GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.rows()
    }

    func positions() -> [Position] where Subject == Grid {
        rows().flatMap(\.items)
    }

    func positions<T>() -> [Position] where Subject == SudokuBoard<T> {
        self.slicedGrid.grid.positions()
    }

    func emptyPositions<T>() -> [Position] where Subject == SudokuBoard<T> {
        positions().filter { subject[$0] == nil } // should we store this list in cache?
    }
}

private struct RowsCache: CachedComputation {
    static func compute(_ cache: Cache<Grid>) -> [GridSlice] {
        Array(Rows(grid: cache.subject))
    }
}
