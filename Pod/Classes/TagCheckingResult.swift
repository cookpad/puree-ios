//
//  TagCheckingResult.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

public class TagCheckingResult {
    private(set) var isMatched: Bool = false
    private(set) var capturedString: String?
    
    static func failure() -> TagCheckingResult {
        let result = TagCheckingResult()
        result.isMatched = false
        
        return result
    }
    
    static func success() -> TagCheckingResult {
        return self.successResult(withCapturedString: nil)
    }
    
    static func successResult(withCapturedString capturedString: String?) -> TagCheckingResult {
        let result = TagCheckingResult()
        result.isMatched = true
        result.capturedString = capturedString
        
        return result
    }
}
