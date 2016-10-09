import Foundation

class PURTestBufferedOutput: PURBufferedOutput {
    var logStorage: TestLogStorage!

    override func configure(settings: [String: Any]) {
        super.configure(settings: settings)

        if let logStorage = settings["logStorage"] as? TestLogStorage {
            self.logStorage = logStorage
        }
    }

    override func write(chunk: PURBufferedOutputChunk, completion: @escaping (Bool) -> Void) {
        let logString = chunk.logs.map { log in
            let userInfo = log.userInfo as! [String: String]
            let record = userInfo.keys.sorted().map { "\($0):\(log.userInfo[$0]!)" }.joined(separator: ",")

            return "{\(log.tag)|\(record)}"
        }.joined()
        self.logStorage.add(log: logString)
        completion(true)
    }
}
