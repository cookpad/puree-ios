import Quick
import Nimble
import Puree

class PURLogStoreSpec: QuickSpec {
    override func spec() {
        describe("readwrite logs") {
            class TestOutputA : PUROutput {}
            class TestOutputB : PUROutput {}

            let date = NSDate().timeIntervalSince1970
            let logStoreDBPath = NSTemporaryDirectory() + "/LogStoreSpec_\(date).db"
            let dummyLogger = PURLogger(configuration: PURLoggerConfiguration())
            let outputA = TestOutputA(logger: dummyLogger, tagPattern: "test.*")
            let outputB = TestOutputB(logger: dummyLogger, tagPattern: "test.*")
            var logStore: PURLogStore!

            beforeSuite {
                logStore = PURLogStore(databasePath: logStoreDBPath)
                logStore.prepare()
            }

            beforeEach {
                logStore.clearAll()
            }

            it("should write log") {
                var count = -1
                logStore.retrieveLogsForPattern("test.*", output:outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(0), timeout: 1)

                logStore.addLog(PURLog(tag: "test.apple", date: NSDate(), userInfo: nil), fromOutput: outputA)
                logStore.addLog(PURLog(tag: "test.apple", date: NSDate(), userInfo: nil), fromOutput: outputA)
                logStore.addLog(PURLog(tag: "test.banana", date: NSDate(), userInfo: nil), fromOutput: outputA)
                logStore.addLog(PURLog(tag: "test.banana", date: NSDate(), userInfo: nil), fromOutput: outputA)
                logStore.addLog(PURLog(tag: "test.apple", date: NSDate(), userInfo: nil), fromOutput: outputB)

                logStore.retrieveLogsForPattern("test.*", output:outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(4), timeout: 1)
            }

            it("should write logs all together") {
                var count = -1
                logStore.retrieveLogsForPattern("test.*", output: outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(0), timeout: 1)

                logStore.addLogs([
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                ], fromOutput:outputA);

                logStore.addLogs([
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                ], fromOutput:outputB);

                logStore.retrieveLogsForPattern("test.*", output: outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(5), timeout: 1)
            }

            it("should remove logs") {
                let firstChunk = [
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                ]

                logStore.addLogs(firstChunk + [
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                ], fromOutput:outputA);

                logStore.addLogs([
                    PURLog(tag: "test.apple", date: NSDate(), userInfo: nil),
                    PURLog(tag: "test.banana", date: NSDate(), userInfo: nil),
                ], fromOutput:outputB);

                var count = -1
                logStore.retrieveLogsForPattern("test.*", output: outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(5), timeout: 1)

                logStore.retrieveLogsForPattern("test.*", output: outputB, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(2), timeout: 1)

                logStore.removeLogs(firstChunk, fromOutput: outputA)

                logStore.retrieveLogsForPattern("test.*", output: outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(3), timeout: 1)

                logStore.retrieveLogsForPattern("test.*", output: outputB, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(2), timeout: 1)
            }
        }

        describe("stress test") {
            let date = NSDate().timeIntervalSince1970
            let logStoreDBPath = NSTemporaryDirectory() + "/LogStoreSpec_\(date).db"
            let dummyLogger = PURLogger(configuration: PURLoggerConfiguration())
            let outputA = PUROutput(logger: dummyLogger, tagPattern: "testA.*")
            let outputB = PUROutput(logger: dummyLogger, tagPattern: "testB.*")
            let outputC = PUROutput(logger: dummyLogger, tagPattern: "testC.*")
            var logStore : PURLogStore!

            beforeSuite {
                logStore = PURLogStore(databasePath: logStoreDBPath)
                logStore.prepare()
            }

            it("write (3 + 3 + 4) * 100 logs (1000 logs)") {
                for _ in 1...100 {
                    logStore.addLogs([
                        PURLog(tag: "testA.apple", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testA.banana", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testA.mango", date: NSDate(), userInfo: nil),
                    ], fromOutput:outputA);

                    logStore.addLogs([
                        PURLog(tag: "testB.apple", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testB.banana", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testB.mango", date: NSDate(), userInfo: nil),
                    ], fromOutput:outputB);

                    logStore.addLogs([
                        PURLog(tag: "testC.apple", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testC.banana", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testC.mango", date: NSDate(), userInfo: nil),
                        PURLog(tag: "testC.peach", date: NSDate(), userInfo: nil),
                    ], fromOutput:outputC);
                }
            }

            it("write 1 * 1000 logs (1000 logs)") {
                for _ in 1...1000 {
                    logStore.addLog(PURLog(tag: "testC.peach", date: NSDate(), userInfo: nil), fromOutput:outputC);
                }
            }

            it("read testA.* logs") {
                var count = -1
                logStore.retrieveLogsForPattern("testA.*", output: outputA, completion: { logs in
                    count = logs.count
                })
                expect(count).toEventually(equal(300), timeout: 3)
            }
        }
    }
}
