//
//  PURTagCheckingResult.swift
//  Pods
//
//  Created by admin on 7/27/17.
//
//

import Foundation

class PURTagCheckingResult {
    private(set) var isMatched: Bool = false
    private(set) var capturedString: String?
    
    static func failure() -> PURTagCheckingResult {
        let result = PURTagCheckingResult()
        result.isMatched = false
        
        return result
    }
    
    static func success() -> PURTagCheckingResult {
        return self.successResult(withCapturedString: nil)
    }
    
    static func successResult(withCapturedString capturedString: String?) -> PURTagCheckingResult {
        let result = PURTagCheckingResult()
        result.isMatched = true
        result.capturedString = capturedString
        
        return result
    }
}
