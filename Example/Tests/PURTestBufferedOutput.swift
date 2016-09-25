import Foundation
import Puree

class PURTestBufferedOutput : PURBufferedOutput {
    var logStorage: TestLogStorage!

    override func configure(_ settings: [String : Any]) {
        super.configure(settings)

        self.logStorage = settings["logStorage"] as! TestLogStorage
    }

    override func write(_ chunk: PURBufferedOutputChunk, completion: @escaping (Bool) -> Void) {
        let logString = chunk.logs.reduce("") { (result, log) -> String in
            let userInfo = log.userInfo as! [String: String]
            let record = userInfo.keys.sorted().map { "\($0)=\(log.userInfo[$0]!)" }.joined(separator: "_")

            return result + "\(log.tag)-\(record)/"
        }
        self.logStorage.addLog(logString)
        completion(true)
    }
}
