extension Cache {
    func regionsWithValues<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[RegionValues<Value>.self]
    }
}

private struct RegionValues<T: Hashable>: CachedComputation {
    static func compute(_ cache: Cache<SudokuBoard<T>>) -> [BoardSlice<T?>] {
        cache.regions().map { slice in
            slice.map { Field(position: $0, value: cache.subject[$0]) }
        }
    }
}
