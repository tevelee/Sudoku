import Foundation

final class EliminatePairsStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]
    private let strategies: (Set<ReservedFields<Value>>) -> [any SudokuSolvingStrategy<Value>]

    init(rules: [any SudokuRule<Value>],
         strategies: @escaping (Set<ReservedFields<Value>>) -> [any SudokuSolvingStrategy<Value>]) {
        self.rules = rules
        self.strategies = strategies
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache<SudokuBoard<Value>>) -> AsyncStream<Move<Value>> {
        let pairs = self.pairs(in: cache.rows() + cache.columns() + cache.regions(), cache: cache)
        return strategies(pairs).map { $0.moves(on: board, cache: cache) }.merged()
    }

    private func pairs(in slices: [GridSlice], cache: Cache<SudokuBoard<Value>>) -> Set<ReservedFields<Value>> {
        var pairs: Set<ReservedFields<Value>> = []
        let covers = cache.covers()
        for slice in slices {
            let coversOfTwo = slice.items.compactMap { position in
                if case .incomplete(let cover) = covers[position], cover.all.count == slice.items.count - 2 {
                    return (position: position, cover: cover)
                }
                return nil
            }
            for (values, pair) in Dictionary(grouping: coversOfTwo, by: { self.allSymbols.subtracting($0.cover.all) }).filter({ $0.value.count == 2 }) {
                pairs.insert(ReservedFields(name: "pairs", values: values, positions: Set(pair.map(\.position))))
            }
        }
        return pairs
    }

    private lazy var allSymbols = contentRule().map { Set($0.allowedSymbols) } ?? []

    private func contentRule() -> ContentRule<Value>? {
        for rule in rules {
            if let contentRule = isContentRule(rule) {
                return contentRule
            }
        }
        return nil
    }

    private func isContentRule(_ value: some SudokuRule<Value>) -> ContentRule<Value>? {
        value as? ContentRule<Value>
    }
}

struct ReservedFields<Value: Hashable>: Hashable {
    let name: String
    let values: Set<Value>
    let positions: Set<Position>

    init(name: String, values: Set<Value>, positions: Set<Position>) {
        precondition(values.count == positions.count)
        self.name = name
        self.values = values
        self.positions = positions
    }

    func reasonPrefix(cache: Cache<SudokuBoard<Value>>) -> String where Value: CustomStringConvertible {
        "Symbols \(values.formatted()) are \(name) in \(positions.map { formatted(position: $0, cache: cache) }.formatted()); "
    }
}

extension Optional {
    func reasonPrefix<Value: CustomStringConvertible>(cache: Cache<SudokuBoard<Value>>) -> String where Wrapped == ReservedFields<Value> {
        map { $0.reasonPrefix(cache: cache) } ?? ""
    }
}
