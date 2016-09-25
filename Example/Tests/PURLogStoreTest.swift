import Puree
import XCTest

class PURLogStoreTest: XCTestCase {
    class TestOutputA: PUROutput {}
    class TestOutputB: PUROutput {}

    static let logStoreDBPath = NSTemporaryDirectory() + "/PureeLogStoreTest.db"
    var logStore: PURLogStore!
    var outputA: TestOutputA!
    var outputB: TestOutputB!
    var outputC: PUROutput!

    override func setUp() {
        let dummyLogger = PURLogger(configuration: PURLoggerConfiguration())
        outputA = TestOutputA(logger: dummyLogger, tagPattern: "test.*")
        outputB = TestOutputB(logger: dummyLogger, tagPattern: "test.*")
        outputC = PUROutput(logger: dummyLogger, tagPattern: "testC.*")

        logStore = PURLogStore(databasePath: PURLogStoreTest.logStoreDBPath)
        logStore.prepare()
    }

    override func tearDown() {
        logStore.clearAll()
    }

    func assertLogStoreLogCount(pattern: String, output: PUROutput, expectedCount: Int, line: Int = #line) {
        let countExpectation = expectation(description: "log count")
        var count = -1
        logStore.retrieveLogs(forPattern: pattern, output:output) { logs in
            count = logs.count
            countExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(count, expectedCount, "line: \(line)")
    }

    func addTestLog(_ log: PURLog, output: PUROutput, description: String) {
        let addExpectation = expectation(description: description)
        logStore.add(log, from: output) { addExpectation.fulfill() }
    }

    func addTestLogs(_ logs: [PURLog], output: PUROutput, description: String) {
        let addExpectation = expectation(description: description)
        logStore.add(logs, from: output) { addExpectation.fulfill() }
    }

    func testAddLog() {
        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 0)

        addTestLog(PURLog(tag: "test.apple", date: Date(), userInfo: nil), output: outputA, description: "add test log 1")
        addTestLog(PURLog(tag: "test.apple", date: Date(), userInfo: nil), output: outputA, description: "add test log 2")
        addTestLog(PURLog(tag: "test.banana", date: Date(), userInfo: nil), output: outputA, description: "add test log 3")
        addTestLog(PURLog(tag: "test.banana", date: Date(), userInfo: nil), output: outputA, description: "add test log 4")
        addTestLog(PURLog(tag: "test.apple", date: Date(), userInfo: nil), output: outputB, description: "add test log 5")

        waitForExpectations(timeout: 1.0, handler: nil)

        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 4)
    }

    func testAddLogs() {
        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 0)

        addTestLogs([
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
        ], output: outputA, description: "add test logs 1")

        addTestLogs([
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
        ], output: outputB, description: "add test logs 1")

        waitForExpectations(timeout: 1.0, handler: nil)

        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 5)
    }

    func testRemoveLogs() {
        let firstChunk = [
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
        ]

        addTestLogs(firstChunk, output: outputA, description: "add test logs 1")

        addTestLogs([
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
        ], output: outputA, description: "add test logs 2")

        addTestLogs([
            PURLog(tag: "test.apple", date: Date(), userInfo: nil),
            PURLog(tag: "test.banana", date: Date(), userInfo: nil),
        ], output: outputB, description: "add test logs 3")

        waitForExpectations(timeout: 1.0, handler: nil)

        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 5)
        assertLogStoreLogCount(pattern: "test.*", output: outputB, expectedCount: 2)

        let removeExpectation = expectation(description: "remove logs")
        logStore.remove(firstChunk, from: outputA) { removeExpectation.fulfill() }

        waitForExpectations(timeout: 1.0, handler: nil)

        assertLogStoreLogCount(pattern: "test.*", output: outputA, expectedCount: 3)
        assertLogStoreLogCount(pattern: "test.*", output: outputB, expectedCount: 2)
    }

    func testStressTest() {
        // write (3 + 3 + 4) * 100 logs (1000 logs)
        for i in 1...100 {
            addTestLogs([
                PURLog(tag: "testA.apple", date: Date(), userInfo: nil),
                PURLog(tag: "testA.banana", date: Date(), userInfo: nil),
                PURLog(tag: "testA.mango", date: Date(), userInfo: nil),
            ], output: outputA, description: "\(i)-A")

            addTestLogs([
                PURLog(tag: "testB.apple", date: Date(), userInfo: nil),
                PURLog(tag: "testB.banana", date: Date(), userInfo: nil),
                PURLog(tag: "testB.mango", date: Date(), userInfo: nil),
            ], output: outputB, description: "\(i)-B")

            addTestLogs([
                PURLog(tag: "testC.apple", date: Date(), userInfo: nil),
                PURLog(tag: "testC.banana", date: Date(), userInfo: nil),
                PURLog(tag: "testC.mango", date: Date(), userInfo: nil),
                PURLog(tag: "testC.peach", date: Date(), userInfo: nil),
            ], output: outputC, description: "\(i)-C")
        }
        waitForExpectations(timeout: 3.0, handler: nil)

        // write 1 * 1000 logs (1000 logs)
        for i in 1...1000 {
            addTestLog(PURLog(tag: "testC.peach", date: Date(), userInfo: nil), output: outputC, description: "\(i)")
        }
        waitForExpectations(timeout: 3.0, handler: nil)

        assertLogStoreLogCount(pattern: "testA.*", output: outputA, expectedCount: 300)
        assertLogStoreLogCount(pattern: "testB.*", output: outputB, expectedCount: 300)
        assertLogStoreLogCount(pattern: "testC.*", output: outputC, expectedCount: 1400)
    }
}
