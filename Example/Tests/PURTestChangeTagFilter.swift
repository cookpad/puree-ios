import Foundation
import Puree

class PURTestChangeTagFilter : PURFilter {
    var tagSuffix: String?

    override func configure(_ settings: [String : AnyObject]) {
        tagSuffix = settings["tagSuffix"] as? String
    }

    override func logs(with object: AnyObject, tag: String, captured: String?) -> [PURLog] {
        guard
            let userInfo = object as? [AnyHashable: Any],
            let suffix = tagSuffix
        else {
            return []
        }

        let newTag = tag + suffix
        return [PURLog(tag: newTag, date: self.logger.currentDate(), userInfo: userInfo)]
    }
}
