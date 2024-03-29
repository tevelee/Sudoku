import XCTest
@testable import SudokuSolver

final class LastPossibleSymbolStrategyTests: XCTestCase {
    func test_whenOneIsMissing_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [1,    2,  nil, nil, nil, nil],
            [nil, nil, nil, 3,   nil, nil],
            [nil, nil, nil, nil, nil, nil],
            [nil, 6,   nil, nil, nil, nil],
            [nil, 4,   nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil]
        ])
        let strategy = LastPossibleSymbolStrategy(rules: [
            ContentRule(allowedSymbols: 1...6),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 5)
        XCTAssertEqual(move.position, Position(row: 1, column: 1))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "5 is the only symbol missing at Row 2, Column 2")
        XCTAssertEqual(reason?.level2, "Row 2 contains 3; Column 2 contains 2, 4, and 6; Region 1 contains 1 and 2")
    }
}
