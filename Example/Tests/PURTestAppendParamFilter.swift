import Foundation
import Puree

class PURTestAppendParamFilter: PURFilter {
    override func logs(object: Any, tag: String, captured: String?) -> [PURLog] {
        guard var userInfo = object as? [String: Any], let ext = captured else {
            return []
        }
        userInfo["ext"] = ext
        return [PURLog(tag: tag, date: self.logger.currentDate(), userInfo: userInfo)]
    }
}
