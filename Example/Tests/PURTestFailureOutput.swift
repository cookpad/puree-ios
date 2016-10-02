import Foundation

class PURTestFailureOutput: PURBufferedOutput {
    var logStorage: TestLogStorage!

    override func configure(settings: [String: Any]) {
        super.configure(settings: settings)

        if let logStorage = settings["logStorage"] as? TestLogStorage {
            self.logStorage = logStorage
        }
    }

    override func write(chunk: PURBufferedOutputChunk, completion: @escaping (Bool) -> Void) {
        self.logStorage.add(log: "error")
        print("\(Date()): error!(retry debug)")
        completion(false)
    }
}
