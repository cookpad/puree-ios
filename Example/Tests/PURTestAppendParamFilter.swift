//
//  PURTestAppendParamFilter.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation
import Puree

class PURTestAppendParamFilter : PURFilter {
    override func logsWithObject(object: AnyObject, tag: String, captured: String?) -> [PURLog] {
        guard
            var userInfo = object as? [NSObject: AnyObject],
            let ext = captured
        else {
            return []
        }

        userInfo["ext"] = ext
        return [PURLog(tag: tag, date: self.logger.currentDate(), userInfo: userInfo)]
    }
}
