import Puree
import XCTest

class PURLoggerTagPatternMatchingTest: XCTestCase {
    func testTagPatternMatching() {
        XCTAssertTrue(PURLogger.matches(tag: "aaa", pattern: "aaa").matched)
        XCTAssertFalse(PURLogger.matches(tag: "aaa", pattern: "bbb").matched)
        XCTAssertTrue(PURLogger.matches(tag: "aaa", pattern: "*").matched)
        XCTAssertTrue(PURLogger.matches(tag: "bbb", pattern: "*").matched)
        XCTAssertFalse(PURLogger.matches(tag: "aaa.bbb", pattern: "*").matched)
        XCTAssertTrue(PURLogger.matches(tag: "aaa.bbb", pattern: "aaa.bbb").matched)
        XCTAssertTrue(PURLogger.matches(tag: "aaa.bbb", pattern: "aaa.*").matched)
        XCTAssertTrue(PURLogger.matches(tag: "aaa.ccc", pattern: "aaa.*").matched)
        XCTAssertFalse(PURLogger.matches(tag: "aaa.bbb.ccc", pattern: "aaa.*").matched)
        XCTAssertFalse(PURLogger.matches(tag: "aaa.bbb.ccc", pattern: "aaa.*.ccc").matched) // deny intermediate wildcard
        XCTAssertFalse(PURLogger.matches(tag: "aaa.ccc.ddd", pattern: "aaa.*.ccc").matched)

        XCTAssertTrue(PURLogger.matches(tag: "a", pattern: "a.**").matched)
        XCTAssertTrue(PURLogger.matches(tag: "a.b", pattern: "a.**").matched)
        XCTAssertTrue(PURLogger.matches(tag: "a.b.c", pattern: "a.**").matched)
        XCTAssertFalse(PURLogger.matches(tag: "b.c", pattern: "a.**").matched)
    }

    func testCapturingWildcard() {
        XCTAssertEqual(PURLogger.matches(tag: "aaa.bbb", pattern: "aaa.*").capturedString, "bbb")
        XCTAssertEqual(PURLogger.matches(tag: "aaa.ccc", pattern: "aaa.*").capturedString, "ccc")

        XCTAssertEqual(PURLogger.matches(tag: "a", pattern: "a.**").capturedString, "")
        XCTAssertEqual(PURLogger.matches(tag: "a.b", pattern: "a.**").capturedString, "b")
        XCTAssertEqual(PURLogger.matches(tag: "a.b.c", pattern: "a.**").capturedString, "b.c")
        XCTAssertNil(PURLogger.matches(tag: "b.c", pattern: "a.**").capturedString)
    }
}
