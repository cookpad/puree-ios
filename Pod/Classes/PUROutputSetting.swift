//
//  PUROutputSetting.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

class PUROutputSetting {
    private(set) var outputClass: Any?
    private(set) var tagPattern: String = ""
    private(set) var settings: [String: Any]?
    
    convenience init(output outputClass: Any,
                     tagPattern: String) {
        self.init(output: outputClass,
                  tagPattern: tagPattern,
                  settings: nil)
    }
    
    init(output outputClass: Any,
         tagPattern: String,
         settings: [String: Any]?) {
        self.outputClass = outputClass
        self.tagPattern = tagPattern
        self.settings = settings
    }
}
