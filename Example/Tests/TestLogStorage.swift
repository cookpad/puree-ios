import Foundation

class TestLogStorage: CustomStringConvertible {
    fileprivate var storage: [String] = []

    func add(log: String) {
        storage.append(log)
    }

    var description: String {
        return storage.map { "[\($0)]" }.joined()
    }
}
