import Foundation
import AsyncAlgorithms

final class OneMissingSymbolStrategy<Value: Hashable & CustomStringConvertible>: SudokuSolvingStrategy {
    private let rules: [any SudokuRule<Value>]

    init(rules: [any SudokuRule<Value>]) {
        self.rules = rules
    }

    func moves(on board: SudokuBoard<Value>, cache: Cache) -> AsyncStream<Move<Value>> {
        let rows = moves(for: board.rows)
        let columns = moves(for: board.columns)
        let regions = moves(for: board.regions)
        return chain(rows, columns, regions).stream()
    }

    private func moves(for slices: some Sequence<BoardSlice<Value>>) -> AsyncStream<Move<Value>> {
        AsyncStream { continuation in
            for slice in slices {
                let items = Set(slice.items.compactMap(\.value))
                if items.count == symbols.count - 1,
                   let emptyPosition = slice.items.first(where: { $0.value == nil })?.position,
                   let missingValue = symbols.subtracting(items).first {
                    let values = slice.items.compactMap(\.value?.description).sorted().list()
                    let move = Move(reason: "\(missingValue) is the only symbol missing from \(slice.name)",
                                    details: "\(slice.name) already contains \(items.count) out of \(symbols.count) values: \(values)",
                                    value: missingValue,
                                    position: emptyPosition)
                    continuation.yield(move)
                }
            }
            continuation.finish()
        }
    }

    private lazy var symbols = contentRule().map { Set($0.allowedSymbols) } ?? []

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

private extension AsyncSequence {
    func stream() -> AsyncStream<Element> {
        .init { continuation in
            Task {
                do {
                    for try await item in self {
                        continuation.yield(item)
                    }
                } catch {}
                continuation.finish()
            }
        }
    }
}
