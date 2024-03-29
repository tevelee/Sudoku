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
        let strategy = OneMissingSymbolStrategy(rules: [
            ContentRule(allowedSymbols: 1...4),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 3)
        XCTAssertEqual(move.position, Position(row: 0, column: 2))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "3 is the only symbol missing from Row 1")
        XCTAssertEqual(reason?.level2, "Row 1 already contains 3 out of 4 values: 1, 2, and 4")
    }

    func test_whenOneIsMissingInColumn_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, 1, nil],
            [nil, nil, nil, nil],
            [nil, nil, 3, nil],
            [nil, nil, 4, nil]
        ])
        let strategy = OneMissingSymbolStrategy(rules: [
            ContentRule(allowedSymbols: 1...4),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 2)
        XCTAssertEqual(move.position, Position(row: 1, column: 2))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "2 is the only symbol missing from Column 3")
        XCTAssertEqual(reason?.level2, "Column 3 already contains 3 out of 4 values: 1, 3, and 4")
    }

    func test_whenOneIsMissingInRegion_thenFindsMove() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, 1, 3],
            [nil, nil, 2, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let strategy = OneMissingSymbolStrategy(rules: [
            ContentRule(allowedSymbols: 1...4),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 4)
        XCTAssertEqual(move.position, Position(row: 1, column: 3))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "4 is the only symbol missing from Region 2")
        XCTAssertEqual(reason?.level2, "Region 2 already contains 3 out of 4 values: 1, 2, and 3")
    }
}
