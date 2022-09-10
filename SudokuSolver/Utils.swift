import Foundation

extension AsyncSequence {
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

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

protocol Apply {}
extension Apply {
    func apply(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}
extension NSObject: Apply {}

extension Array {
    func merged<T>() -> AsyncStream<T> where Element: AsyncSequence, Element.Element == T {
        .init { continuation in
            Task {
                for stream in self {
                    do {
                        for try await item in stream {
                            continuation.yield(item)
                        }
                    } catch {
                        continuation.finish()
                    }
                }
                continuation.finish()
            }
        }
    }
}

extension Collection where Element: CustomStringConvertible {
    func formatted(formatter: ListFormatter = .english) -> String {
        map(\.description).sorted().list(formatter: formatter)
    }
}

extension Array where Element: CustomStringConvertible {
    func list(formatter: ListFormatter = .english) -> String {
        formatter.string(from: self) ?? map(\.description).joined(separator: ", ")
    }
}

extension ListFormatter {
    static let english = ListFormatter().apply {
        $0.locale = Locale(identifier: "en-US")
    }
}
