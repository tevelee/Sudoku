import Foundation

public struct ContentRule {
    public let allowedSymbols: [String]
}

public struct UniqueSymbolsRule {
    public let slices: [Slice<Position>]
}
