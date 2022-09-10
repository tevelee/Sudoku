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
