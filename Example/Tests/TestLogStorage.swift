//
//  TestLogStorage.swift
//  Puree
//
//  Created by tomohiro-moro on 12/10/14.
//  Copyright (c) 2014 Tomohiro Moro. All rights reserved.
//

import Foundation

class TestLogStorage {
    var storage: [String] = []

    func addLog(log: String) {
        storage.append(log)
    }

    func toString() -> String {
        return storage.joinWithSeparator(", ")
    }
}
