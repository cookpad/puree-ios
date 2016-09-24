import Foundation
import Puree

class PURTestFailureOutput : PURBufferedOutput {
    var logStorage: TestLogStorage!

    override func configure(_ settings: [String : AnyObject]) {
        super.configure(settings)

        self.logStorage = settings["logStorage"] as! TestLogStorage
    }

    override func write(_ chunk: PURBufferedOutputChunk, completion: (Bool) -> Void) {
        self.logStorage.addLog("error");
        print("\(Date()): error!(retry debug)")
        completion(false)
    }
}
