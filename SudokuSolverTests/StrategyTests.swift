import XCTest
@testable import SudokuSolver

final class SudokuSolverStrategyTests: XCTestCase {
    func test_whenOneIsMissing_thenFindsMove() throws {
        // Given
        let board = try! SudokuBoard([
            [1, 2, nil, 4],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = OneMissingElementStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 3)
        XCTAssertEqual(move.position, Position(row: 0, column: 2))
        XCTAssertEqual(move.reason, "One missing value in Row 1")
    }
}
