//
//  PURFailureOutput.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation
import Puree

class PURTestFailureOutput : PURBufferedOutput {
    var logStorage: TestLogStorage!

    override func configure(settings: [NSObject : AnyObject]?) {
        super.configure(settings)

        self.logStorage = settings!["logStorage"] as! TestLogStorage
    }

    override func writeChunk(chunk: PURBufferedOutputChunk, completion: (Bool) -> Void) {
        self.logStorage.addLog("error");
        print("\(NSDate()): error!(retry debug)")
        completion(false)
    }
}
