extension Cache {
    func regionForPosition() -> [Position: GridSlice] where Subject == SlicedGrid {
        self[RegionForPosition.self]
    }

    func regionForPosition<T>() -> [Position: GridSlice] where Subject == SudokuBoard<T> {
        self.slicedGrid.regionForPosition()
    }

    func region<T>(for position: Position) -> GridSlice? where Subject == SudokuBoard<T> {
        regionForPosition()[position]
    }
}

private struct RegionForPosition: CachedComputation {
    static func compute(_ cache: Cache<SlicedGrid>) -> [Position: GridSlice] {
        var result: [Position: GridSlice] = [:]
        for slice in cache.subject.slices {
            for position in slice.items {
                result[position] = slice
            }
        }
        return result
    }
}
