import Foundation
import Puree

class PURTestOutput : PUROutput {
    var logStorage: TestLogStorage!

    override func configure(_ settings: [String : Any]) {
        super.configure(settings)

        self.logStorage = settings["logStorage"] as! TestLogStorage
    }

    override func emitLog(_ log: PURLog) {
        let userInfo = log.userInfo as! [String: String]
        let record = userInfo.keys.sorted().map { "\($0)=\(log.userInfo[$0]!)" }.joined(separator: "_")
        self.logStorage.addLog("\(log.tag)-\(record)")
    }
}
