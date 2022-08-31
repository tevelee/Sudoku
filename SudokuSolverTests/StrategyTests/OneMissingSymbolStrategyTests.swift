import XCTest
@testable import SudokuSolver

final class OneMissingSymbolStrategyTests: XCTestCase {
    func test_whenOneIsMissingInRow_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [1, 2, nil, 4],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = OneMissingSymbolStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 3)
        XCTAssertEqual(move.position, Position(row: 0, column: 2))
        XCTAssertEqual(move.reason, "3 is the only symbol missing from Row 1")
    }

    func test_whenOneIsMissingInColumn_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, 1, nil],
            [nil, nil, nil, nil],
            [nil, nil, 3, nil],
            [nil, nil, 4, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = OneMissingSymbolStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 2)
        XCTAssertEqual(move.position, Position(row: 1, column: 2))
        XCTAssertEqual(move.reason, "2 is the only symbol missing from Column 3")
    }

    func test_whenOneIsMissingInRegion_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, 1, 3],
            [nil, nil, 2, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = OneMissingSymbolStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 4)
        XCTAssertEqual(move.position, Position(row: 1, column: 3))
        XCTAssertEqual(move.reason, "4 is the only symbol missing from Region 2")
    }
}
