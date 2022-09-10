import XCTest
@testable import SudokuSolver

final class EliminatePairsStrategyTests: XCTestCase {
    func test_whenThereArePairs_thenTheyCanBeEliminated_usingOneMissingSymbol() async throws {
        // Given
        let board = try! SudokuBoard([

            [nil, nil, nil, nil],
            [nil,   4, nil, nil],
            [3,   nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let rules: [any SudokuRule<Int>] = [contentRule, uniquenessRule]
        let strategy = EliminatePairsStrategy(rules: rules) { reservedFields in
            [
                OneMissingSymbolStrategy(rules: rules, reservedFields: reservedFields)
            ]
        }

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 4)
        XCTAssertEqual(move.position, Position(row: 3, column: 0))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "Symbols 1 and 2 are pairs in Row 1 Column 1 and Row 2 Column 1; 4 is the only symbol missing from Column 1")
    }

    func test_whenThereArePairs_thenTheyCanBeEliminated_usingLastPossibleSymbol() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, nil],
            [nil,   4, nil, nil],
            [3,   nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let rules: [any SudokuRule<Int>] = [contentRule, uniquenessRule]
        let strategy = EliminatePairsStrategy(rules: rules) { reservedFields in
            [
                LastPossibleSymbolStrategy(rules: rules, reservedFields: reservedFields)
            ]
        }

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 3)
        XCTAssertEqual(move.position, Position(row: 0, column: 1))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "Symbols 1 and 2 are pairs in Row 3 Column 2 and Row 4 Column 2; 3 is the only symbol missing at Row 1, Column 2")
    }
}
