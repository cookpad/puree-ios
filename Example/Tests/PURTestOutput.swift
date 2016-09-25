import Foundation
import Puree

class PURTestOutput: PUROutput {
    var logStorage: TestLogStorage!

    override func configure(settings: [String: Any]) {
        super.configure(settings: settings)

        if let logStorage = settings["logStorage"] as? TestLogStorage {
            self.logStorage = logStorage
        }
    }

    override func emit(log: PURLog) {
        let userInfo = log.userInfo as! [String: String]
        let record = userInfo.keys.sorted().map { "\($0):\(log.userInfo![$0]!)" }.joined(separator: ",")
        self.logStorage.add(log: "\(log.tag)|\(record)")
    }
}
