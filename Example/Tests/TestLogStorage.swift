import Foundation

class TestLogStorage {
    fileprivate var storage: [String] = []

    func addLog(_ log: String) {
        storage.append(log)
    }

    func toString() -> String {
        return storage.joined(separator: ", ")
    }
}
