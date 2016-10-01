import Puree
import XCTest

class PURLoggerStandardPluginTest: XCTestCase {
    class TestLoggerConfiguration: PURLoggerConfiguration {
        let logStorage = TestLogStorage()
        let logStoreOperationDispatchQueue = DispatchQueue(label: "Puree logger test")
    }

    var loggerConfiguration: TestLoggerConfiguration!
    var logger: PURLogger!

    var testLogStorage: TestLogStorage {
        return loggerConfiguration.logStorage
    }

    override func setUp() {
        let configuration = TestLoggerConfiguration()
        let logStoreDBPath = NSTemporaryDirectory() + "/PureeLoggerTest-\(UUID().uuidString).db"
        let logStore = PURLogStore(databasePath: logStoreDBPath)
        let logStorage = configuration.logStorage

        configuration.logStore = logStore
        configuration.filterSettings = [
            PURFilterSetting(filter: PURTestChangeTagFilter.self, tagPattern: "filter.test", settings: ["tagSuffix": "XXX"]),
            PURFilterSetting(filter: PURTestAppendParamFilter.self, tagPattern: "filter.append.**"),
        ]
        configuration.outputSettings = [
            PUROutputSetting(output: PURTestOutput.self, tagPattern: "filter.testXXX", settings: ["logStorage": logStorage]),
            PUROutputSetting(output: PURTestOutput.self, tagPattern: "filter.append.**", settings: ["logStorage": logStorage]),
            PUROutputSetting(output: PURTestOutput.self, tagPattern: "test.*", settings: ["logStorage": logStorage]),
            PUROutputSetting(output: PURTestOutput.self, tagPattern: "unbuffered", settings: ["logStorage": logStorage]),
            PUROutputSetting(output: PURTestBufferedOutput.self, tagPattern: "buffered.*", settings: ["logStorage": logStorage, PURBufferedOutputSettingsFlushIntervalKey: 2]),
            PUROutputSetting(output: PURTestFailureOutput.self, tagPattern: "failure", settings: ["logStorage": logStorage]),
        ]

        loggerConfiguration = configuration
        logger = PURLogger(configuration: configuration)
    }

    override func tearDown() {
        logger.logStore().clearAll()
        logger.shutdown()
    }

    func testChangeTagFilterPlugin() {
        XCTAssertEqual(testLogStorage.description, "")

        logger.post(["aaa": "123"], tag: "filter.test")
        logger.post(["bbb": "456", "ccc": "789"], tag: "filter.test")
        logger.post(["ddd": "12345"], tag: "debug")
        logger.post(["eee": "not filtered"], tag: "filter.testXXX")

        XCTAssertEqual(testLogStorage.description, "[filter.testXXX|aaa:123][filter.testXXX|bbb:456,ccc:789][filter.testXXX|eee:not filtered]")
    }

    func testAppendParamFilterPlugin() {
        XCTAssertEqual(testLogStorage.description, "")

        logger.post(["aaa": "123"], tag: "filter.append")
        logger.post(["bbb": "456"], tag: "filter.append.xxx")
        logger.post(["ddd": "12345"], tag: "debug")
        logger.post(["ccc": "789"], tag: "filter.append.yyy")

        XCTAssertEqual(testLogStorage.description, "[filter.append|aaa:123,ext:][filter.append.xxx|bbb:456,ext:xxx][filter.append.yyy|ccc:789,ext:yyy]")
    }

    func testUnbufferedOutputPlugin() {
        XCTAssertEqual(testLogStorage.description, "")

        logger.post(["aaa": "123"], tag: "test.hoge")
        logger.post(["bbb": "456", "ccc": "789"], tag: "test.fuga")
        logger.post(["ddd": "12345"], tag: "debug")

        XCTAssertEqual(testLogStorage.description, "[test.hoge|aaa:123][test.fuga|bbb:456,ccc:789]")
    }

    func testBufferedOutputPlugin_writeLog() {
        expectation(forNotification: Notification.Name.PURBufferedOutputDidStart.rawValue, object: nil, handler: nil)
        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(testLogStorage.description, "")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidSuccessWriteChunk.rawValue, object: nil, handler: nil)

        logger.post(["aaa": "1"], tag: "buffered.a")
        logger.post(["aaa": "2"], tag: "buffered.a")
        logger.post(["aaa": "3"], tag: "buffered.b")

        XCTAssertEqual(testLogStorage.description, "")

        logger.post(["aaa": "4"], tag: "buffered.b")
        logger.post(["zzz": "###"], tag: "unbuffered")
        logger.post(["aaa": "5"], tag: "buffered.a") // <- flush!

        // stay in buffer
        logger.post(["aaa": "6"], tag: "buffered.a")

        waitForExpectations(timeout: 1.0, handler: nil)

        let logStorageContent = testLogStorage.description
        XCTAssertTrue(logStorageContent.contains("[unbuffered|zzz:###]"))
        XCTAssertTrue(logStorageContent.contains("{buffered.a|aaa:1}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.a|aaa:2}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.b|aaa:3}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.b|aaa:4}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.a|aaa:5}"))
        XCTAssertFalse(logStorageContent.contains("{buffered.a|aaa:6}"))
    }

    func testBufferedOutputPlugin_resumeStoredLogs() {
        expectation(forNotification: Notification.Name.PURBufferedOutputDidStart.rawValue, object: nil, handler: nil)
        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(testLogStorage.description, "")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidSuccessWriteChunk.rawValue, object: nil, handler: nil)

        logger.post(["aaa": "1"], tag: "buffered.c")
        logger.post(["aaa": "2"], tag: "buffered.c")
        logger.post(["aaa": "3"], tag: "buffered.d")

        XCTAssertEqual(testLogStorage.description, "")

        logger.shutdown()
        expectation(forNotification: Notification.Name.PURBufferedOutputDidStart.rawValue, object: nil, handler: nil)

        // renewal logger!
        logger = PURLogger(configuration: loggerConfiguration) // <- flush!

        waitForExpectations(timeout: 1.0, handler: nil)

        logger.post(["aaa": "4"], tag: "buffered.d") // stay in buffer
        logger.post(["zzz": "###"], tag: "unbuffered")
        logger.post(["aaa": "5"], tag: "buffered.c") // stay in buffer
        logger.post(["aaa": "6"], tag: "buffered.c") // stay in buffer

        let logStorageContent = testLogStorage.description
        XCTAssertTrue(logStorageContent.contains("[unbuffered|zzz:###]"))
        XCTAssertTrue(logStorageContent.contains("{buffered.c|aaa:1}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.c|aaa:2}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.d|aaa:3}"))

        XCTAssertFalse(logStorageContent.contains("{buffered.d|aaa:4}"))
        XCTAssertFalse(logStorageContent.contains("{buffered.c|aaa:5}"))
        XCTAssertFalse(logStorageContent.contains("{buffered.c|aaa:6}"))
    }

    func testBufferedOutputPlugin_periodicalFlushing() {
        expectation(forNotification: Notification.Name.PURBufferedOutputDidStart.rawValue, object: nil, handler: nil)
        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(testLogStorage.description, "")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidSuccessWriteChunk.rawValue, object: nil, handler: nil)

        logger.post(["aaa": "1"], tag: "buffered.e")
        logger.post(["aaa": "2"], tag: "buffered.e")
        logger.post(["aaa": "3"], tag: "buffered.f")

        XCTAssertEqual(testLogStorage.description, "")

        // wait flush interval(2sec) ...
        waitForExpectations(timeout: 3.0, handler: nil)

        let logStorageContent = testLogStorage.description
        XCTAssertTrue(logStorageContent.contains("{buffered.e|aaa:1}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.e|aaa:2}"))
        XCTAssertTrue(logStorageContent.contains("{buffered.f|aaa:3}"))
    }

    func testBufferedOutputPlugin_retry() {
        expectation(forNotification: Notification.Name.PURBufferedOutputDidStart.rawValue, object: nil, handler: nil)
        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(testLogStorage.description, "")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidTryWriteChunk.rawValue, object: nil, handler: nil)

        logger.post(["aaa": "1"], tag: "failure")
        logger.post(["aaa": "2"], tag: "failure")
        logger.post(["aaa": "3"], tag: "failure")
        logger.post(["aaa": "4"], tag: "failure")
        logger.post(["aaa": "5"], tag: "failure")

        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertEqual(testLogStorage.description, "[error]")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidTryWriteChunk.rawValue, object: nil, handler: nil)
        // scheduled after 2sec
        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertEqual(testLogStorage.description, "[error][error]")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidTryWriteChunk.rawValue, object: nil, handler: nil)
        // scheduled after 4sec
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertEqual(testLogStorage.description, "[error][error][error]")

        expectation(forNotification: Notification.Name.PURBufferedOutputDidTryWriteChunk.rawValue, object: nil, handler: nil)
        // scheduled after 8sec
        waitForExpectations(timeout: 9.0, handler: nil)
        XCTAssertEqual(testLogStorage.description, "[error][error][error][error]")
    }
}
