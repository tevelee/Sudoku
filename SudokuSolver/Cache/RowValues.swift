extension Cache {
    func rowsWithValues<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[RowValues<Value>.self]
    }
}

private struct RowValues<T: Hashable>: CachedComputation {
    static func compute(_ cache: Cache<SudokuBoard<T>>) -> [BoardSlice<T?>] {
        cache.rows().map { slice in
            slice.map { Field(position: $0, value: cache.subject[$0]) }
        }
    }
}
