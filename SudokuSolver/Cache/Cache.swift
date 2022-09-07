import Foundation

public protocol CachedComputation {
    associatedtype Subject
    associatedtype Value: Hashable

    static func compute(_ board: Cache<Subject>) -> Value
}

@dynamicMemberLookup
public class Cache<Subject> {
    let subject: Subject
    private var childCaches: [ObjectIdentifier: Any] = [:]
    private var cachedObjects: [ObjectIdentifier: AnyHashable] = [:]

    public init(_ subject: Subject) {
        self.subject = subject
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Subject, T>) -> Cache<T> {
        get {
            let id = ObjectIdentifier(type(of: keyPath))
            if let cache = childCaches[id] as? Cache<T> {
                return cache
            } else {
                let part = subject[keyPath: keyPath]
                let cache = Cache<T>(part)
                childCaches[id] = cache
                return cache
            }
        }
        set {
            let id = ObjectIdentifier(type(of: keyPath))
            childCaches[id] = newValue
        }
    }

    public subscript<O: CachedComputation>(object: O.Type) -> O.Value where O.Subject == Subject {
        let id = ObjectIdentifier(object)
        if let value = cachedObjects[id]?.base as? O.Value {
            return value
        }
        let value = O.compute(self)
        cachedObjects[id] = AnyHashable(value)
        return value
    }
}
