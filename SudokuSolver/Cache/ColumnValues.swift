extension Cache {
    func columnsWithValues<Value: Hashable>() -> [BoardSlice<Value?>] where Subject == SudokuBoard<Value> {
        self[ColumnValues<Value>.self]
    }
}

private struct ColumnValues<T: Hashable>: CachedComputation {
    static func compute(_ cache: Cache<SudokuBoard<T>>) -> [BoardSlice<T?>] {
        cache.columns().map { slice in
            slice.map { Field(position: $0, value: cache.subject[$0]) }
        }
    }
}
