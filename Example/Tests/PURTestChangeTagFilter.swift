//
//  PURTestChangeTagFilter.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation
import Puree

class PURTestChangeTagFilter : PURFilter {
    var tagSuffix: String!
    override func configure(settings: [NSObject : AnyObject]!) {
        tagSuffix = settings["tagSuffix"] as! String!
    }

    override func logsWithObject(object: AnyObject!, tag: String!, captured: String!) -> [AnyObject]! {
        let newTag = tag + tagSuffix

        return [PURLog(tag: newTag, date: NSDate(), userInfo: object as! [NSObject : AnyObject])]
    }
}
