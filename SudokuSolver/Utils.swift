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
