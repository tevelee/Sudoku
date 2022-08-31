import XCTest
@testable import SudokuSolver

final class LastRemainingCellStrategyTests: XCTestCase {
    func test_whenNumberCoversCellsInRegion_thenFindsMissing() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, nil],
            [nil, nil, 2,   nil],
            [2,   nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...4)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = LastRemainingCellStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 2)
        XCTAssertEqual(move.position, Position(row: 0, column: 1))
        XCTAssertEqual(move.reason, "Symbol 2 covers all fields in Region 1 except Row 1, Column 2")
        XCTAssertEqual(move.details, "In Region 1, Row 2 and Column 1 contain 2, it must be at Row 1, Column 2")
    }

    func test_whenNumberCoversCellsInLargerRegion_thenFindsMissing() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, 2, nil, nil],
            [nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, 2],
            [2, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil],
            [nil, nil, nil, nil, nil, nil]
        ])
        let contentRule = ContentRule(allowedSymbols: 1...6)
        let uniquenessRule = UniqueSymbolsRule(rowsAndColumnsAndRegions: board)
        let strategy = LastRemainingCellStrategy(rules: [contentRule, uniquenessRule])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 2)
        XCTAssertEqual(move.position, Position(row: 1, column: 1))
        XCTAssertEqual(move.reason, "Symbol 2 covers all fields in Region 1 except Row 2, Column 2")
        XCTAssertEqual(move.details, "In Region 1, Row 1, Row 3, and Column 1 contain 2, it must be at Row 2, Column 2")

        XCTAssertEqual(SudokuBoardPrinter(renderer: BoxedRenderer(style: .leveled(.singleAndDouble))).print(board), """
        ╔═══╤═══╦═══╤═══╦═══╤═══╗
        ║   │   ║   │ 2 ║   │   ║
        ╟───┼───╫───┼───╫───┼───╢
        ║   │   ║   │   ║   │   ║
        ╟───┼───╫───┼───╫───┼───╢
        ║   │   ║   │   ║   │ 2 ║
        ╠═══╪═══╬═══╪═══╬═══╪═══╣
        ║ 2 │   ║   │   ║   │   ║
        ╟───┼───╫───┼───╫───┼───╢
        ║   │   ║   │   ║   │   ║
        ╟───┼───╫───┼───╫───┼───╢
        ║   │   ║   │   ║   │   ║
        ╚═══╧═══╩═══╧═══╩═══╧═══╝
        """)
    }
}
