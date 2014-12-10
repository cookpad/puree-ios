//
//  PURTestAppendParamFilter.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation

class PURTestAppendParamFilter : PURFilter {
    override func logsWithObject(object: AnyObject!, tag: String!, captured: String!) -> [AnyObject]! {
        var userInfo = (object as NSDictionary).mutableCopy() as NSMutableDictionary
        userInfo["ext"] = captured;

        return [PURLog(tag: tag, date: NSDate(), userInfo: userInfo)]
    }
}
