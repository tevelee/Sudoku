import XCTest
@testable import SudokuSolver
import AsyncAlgorithms

final class LastRemainingCellStrategyTests: XCTestCase {
    func test_whenNumberCoversCellsInRegion_thenFindsMissing() async throws {
        // Given
        let board = try! SudokuBoard([
            [nil, nil, nil, nil],
            [nil, nil, 2,   nil],
            [2,   nil, nil, nil],
            [nil, nil, nil, nil]
        ])
        let strategy = LastRemainingCellStrategy(rules: [
            ContentRule(allowedSymbols: 1...4),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.distinctMoves(on: board)

        // Then
        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(result, [
            Move(value: 2, position: Position(row: 3, column: 3), reasons: [
                .init(level1 : "Symbol 2 covers all fields in Row 4 except Region 4, Column 4",
                      level2 : "In Row 4, Region 3, Column 1, and Column 3 contain 2, it must be at Region 4, Column 4"),
                .init(level1 : "Symbol 2 covers all fields in Region 4 except Row 4, Column 4",
                      level2 : "In Region 4, Row 3 and Column 3 contain 2, it must be at Row 4, Column 4"),
                .init(level1 : "Symbol 2 covers all fields in Column 4 except Row 4, Region 4",
                      level2 : "In Column 4, Row 2, Row 3, and Region 2 contain 2, it must be at Row 4, Region 4")
            ]),
            Move(value: 2, position: Position(row: 0, column: 1), reasons: [
                .init(level1 : "Symbol 2 covers all fields in Region 1 except Row 1, Column 2",
                      level2 : "In Region 1, Row 2 and Column 1 contain 2, it must be at Row 1, Column 2"),
                .init(level1 : "Symbol 2 covers all fields in Row 1 except Region 1, Column 2",
                      level2 : "In Row 1, Region 2, Column 1, and Column 3 contain 2, it must be at Region 1, Column 2"),
                .init(level1 : "Symbol 2 covers all fields in Column 2 except Row 1, Region 1",
                      level2 : "In Column 2, Row 2, Row 3, and Region 3 contain 2, it must be at Row 1, Region 1")
            ]),
        ])
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
        let strategy = LastRemainingCellStrategy(rules: [
            ContentRule(allowedSymbols: 1...6),
            UniqueSymbolsRule()
        ])

        // When
        let result = await strategy.nextMove(on: board)

        // Then
        let move = try XCTUnwrap(result)
        XCTAssertEqual(move.value, 2)
        XCTAssertEqual(move.position, Position(row: 1, column: 1))
        let reason = move.reasons.first
        XCTAssertEqual(reason?.level1, "Symbol 2 covers all fields in Region 1 except Row 2, Column 2")
        XCTAssertEqual(reason?.level2, "In Region 1, Row 1, Row 3, and Column 1 contain 2, it must be at Row 2, Column 2")

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
