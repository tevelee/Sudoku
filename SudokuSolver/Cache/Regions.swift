extension Cache {
    func regions() -> [GridSlice] where Subject == SlicedGrid {
        self[RegionsCache.self]
    }

    func regions<T>() -> [GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.regions()
    }
}

private struct RegionsCache: CachedComputation {
    static func compute(_ cache: Cache<SlicedGrid>) -> [GridSlice] {
        Array(cache.subject.slices)
    }
}
