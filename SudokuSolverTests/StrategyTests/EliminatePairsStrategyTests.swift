import XCTest
@testable import SudokuSolver

final class EliminatePairsStrategyTests: XCTestCase {
    func test_whenThereArePairs_thenTheyCanBeEliminated() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, nil],
            [nil,   4, nil, nil],
            [3,   nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = EliminatePairsStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 1)
        XCTAssertEqual(move.position, Position(row: 3, column: 0))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "Symbols 1 and 2 are pairs in Row 1 Column 1 and Row 1 Column 2; 4 is the only symbol missing from Column 1")
        // EliminatePairs + OneMissing
        // TODO: Board<PossibleValue<Int>>, enum PossibleValue<T> { case known(T), possible([T]) }
    }
}