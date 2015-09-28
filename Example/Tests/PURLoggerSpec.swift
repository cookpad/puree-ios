import Quick
import Nimble
import Puree
import CocoaLumberjack

class PURLoggerSpec: QuickSpec {
    override func spec() {
        beforeSuite({
            DDLog.addLogger(DDTTYLogger.sharedInstance())
        })

        describe("tag pattern matching") {
            it("should pattern matching tags") {
                expect(PURLogger.matchesTag("aaa",         pattern: "aaa"      ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("aaa",         pattern: "bbb"      ).matched).to(beFalsy());
                expect(PURLogger.matchesTag("aaa",         pattern: "*"        ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("bbb",         pattern: "*"        ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("aaa.bbb",     pattern: "*"        ).matched).to(beFalsy());
                expect(PURLogger.matchesTag("aaa.bbb",     pattern: "aaa.bbb"  ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("aaa.bbb",     pattern: "aaa.*"    ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("aaa.ccc",     pattern: "aaa.*"    ).matched).to(beTruthy());
                expect(PURLogger.matchesTag("aaa.bbb.ccc", pattern: "aaa.*"    ).matched).to(beFalsy());
                expect(PURLogger.matchesTag("aaa.bbb.ccc", pattern: "aaa.*.ccc").matched).to(beFalsy()); // deny intermediate wildcard
                expect(PURLogger.matchesTag("aaa.ccc.ddd", pattern: "aaa.*.ccc").matched).to(beFalsy());

                expect(PURLogger.matchesTag("a",     pattern: "a.**").matched).to(beTruthy());
                expect(PURLogger.matchesTag("a.b",   pattern: "a.**").matched).to(beTruthy());
                expect(PURLogger.matchesTag("a.b.c", pattern: "a.**").matched).to(beTruthy());
                expect(PURLogger.matchesTag("b.c",   pattern: "a.**").matched).to(beFalsy());
            }

            it("should capture wildcard") {
                expect(PURLogger.matchesTag("aaa.bbb", pattern: "aaa.*").capturedString).to(equal("bbb"));
                expect(PURLogger.matchesTag("aaa.ccc", pattern: "aaa.*").capturedString).to(equal("ccc"));

                expect(PURLogger.matchesTag("a",       pattern: "a.**").capturedString).to(equal(""));
                expect(PURLogger.matchesTag("a.b",     pattern: "a.**").capturedString).to(equal("b"));
                expect(PURLogger.matchesTag("a.b.c",   pattern: "a.**").capturedString).to(equal("b.c"));
                expect(PURLogger.matchesTag("b.c",     pattern: "a.**").capturedString).to(beNil());
            }
        }

        describe("logger function") {
            let date = NSDate().timeIntervalSince1970
            let logStoreDBPath = NSTemporaryDirectory() + "/LoggerSpec_\(date).db"
            var logger : PURLogger!
            var testLogStorage : TestLogStorage!
            let configuration = PURLoggerConfiguration()

            beforeEach {
                testLogStorage = TestLogStorage()
                configuration.logStore = PURLogStore(databasePath: logStoreDBPath);
                configuration.filterSettings = [
                    PURFilterSetting(filter: PURTestChangeTagFilter.self, tagPattern: "filter.test", settings: ["tagSuffix": "123"]),
                    PURFilterSetting(filter: PURTestAppendParamFilter.self, tagPattern: "filter.append.**"),
                ]
                configuration.outputSettings = [
                    PUROutputSetting(output: PURTestOutput.self,         tagPattern: "filter.test123",   settings: ["logStorage": testLogStorage]),
                    PUROutputSetting(output: PURTestOutput.self,         tagPattern: "filter.append.**", settings: ["logStorage": testLogStorage]),
                    PUROutputSetting(output: PURTestOutput.self,         tagPattern: "test.*",           settings: ["logStorage": testLogStorage]),
                    PUROutputSetting(output: PURTestOutput.self,         tagPattern: "unbuffered",       settings: ["logStorage": testLogStorage]),
                    PUROutputSetting(output: PURTestBufferedOutput.self, tagPattern: "buffered.*",       settings: ["logStorage": testLogStorage, PURBufferedOutputSettingsFlushIntervalKey: 2]),
                    PUROutputSetting(output: PURTestFailureOutput.self,  tagPattern: "important",        settings: ["logStorage": testLogStorage]),
                ]
                logger = PURLogger(configuration: configuration)
            }

            afterEach {
                configuration.logStore.clearAll()
                logger.shutdown()
            }

            describe("change tag filter plugin") {
                it("should reaction replaced tag pattern") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "123"], tag: "filter.test")
                    logger.postLog(["bbb": "456", "ccc": "789"], tag: "filter.test")
                    logger.postLog(["ddd": "12345"], tag: "debug")
                    logger.postLog(["eee": "not filtered"], tag: "filter.test123")

                    expect(testLogStorage.toString()).to(equal("filter.test123-aaa=123, filter.test123-bbb=456_ccc=789, filter.test123-eee=not filtered"))
                }
            }

            describe("append param filter plugin") {
                it("should reaction appended logs") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "123"], tag: "filter.append")
                    logger.postLog(["bbb": "456"], tag: "filter.append.xxx")
                    logger.postLog(["ddd": "12345"], tag: "debug")
                    logger.postLog(["ccc": "789"], tag: "filter.append.yyy")

                    expect(testLogStorage.toString()).to(equal("filter.append-aaa=123_ext=, filter.append.xxx-bbb=456_ext=xxx, filter.append.yyy-ccc=789_ext=yyy"))
                }
            }

            describe("unbuffered output plugin") {
                it("should write unbuffered log") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "123"], tag: "test.hoge")
                    logger.postLog(["bbb": "456", "ccc": "789"], tag: "test.fuga")
                    logger.postLog(["ddd": "12345"], tag: "debug")

                    expect(testLogStorage.toString()).to(equal("test.hoge-aaa=123, test.fuga-bbb=456_ccc=789"))
                }
            }

            describe("buffered output plugin") {
                it("should write buffered log") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "1"], tag: "buffered.a")
                    logger.postLog(["aaa": "2"], tag: "buffered.a")
                    logger.postLog(["aaa": "3"], tag: "buffered.b")

                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "4"], tag: "buffered.b")
                    logger.postLog(["zzz": "###"], tag: "unbuffered")
                    logger.postLog(["aaa": "5"], tag: "buffered.a") // <- flush!

                    // remain in buffer
                    logger.postLog(["aaa": "6"], tag: "buffered.a")

                    expect(testLogStorage.toString()).toEventually(contain(
                        "unbuffered-zzz=###",
                        "buffered.a-aaa=1",
                        "buffered.a-aaa=2",
                        "buffered.b-aaa=3",
                        "buffered.b-aaa=4",
                        "buffered.a-aaa=5"
                    ), timeout: 1)
                }

                it("should resume stored logs") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "1"], tag: "buffered.c")
                    logger.postLog(["aaa": "2"], tag: "buffered.c")
                    logger.postLog(["aaa": "3"], tag: "buffered.d")

                    expect(testLogStorage.toString()).to(equal(""))

                    // renewal logger!
                    logger.shutdown()
                    logger = PURLogger(configuration: configuration) // <- flush!

                    logger.postLog(["aaa": "4"], tag: "buffered.d") // remain in buffer
                    logger.postLog(["zzz": "###"], tag: "unbuffered")
                    logger.postLog(["aaa": "5"], tag: "buffered.c") // remain in buffer
                    logger.postLog(["aaa": "6"], tag: "buffered.c") // remain in buffer

                    expect(testLogStorage.toString()).toEventually(contain(
                        "unbuffered-zzz=###",
                        "buffered.c-aaa=1",
                        "buffered.c-aaa=2",
                        "buffered.d-aaa=3"
                        ), timeout: 1)
                }

                it("should flush logs by flush interval") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "1"], tag: "buffered.e")
                    logger.postLog(["aaa": "2"], tag: "buffered.e")
                    logger.postLog(["aaa": "3"], tag: "buffered.f")

                    expect(testLogStorage.toString()).to(equal(""))

                    // waiting 2 sec...

                    expect(testLogStorage.toString()).toEventually(contain(
                        "buffered.e-aaa=1",
                        "buffered.e-aaa=2",
                        "buffered.f-aaa=3"
                        ), timeout: 5)
                }

                it("should retry flush logs") {
                    expect(testLogStorage.toString()).to(equal(""))

                    logger.postLog(["aaa": "1"], tag: "important")
                    logger.postLog(["aaa": "2"], tag: "important")
                    logger.postLog(["aaa": "3"], tag: "important")
                    logger.postLog(["aaa": "4"], tag: "important")
                    logger.postLog(["aaa": "5"], tag: "important")

                    expect(testLogStorage.toString()).toEventually(equal("error"), timeout: 2)
                    expect(testLogStorage.toString()).toEventually(equal("error, error"), timeout: 4)
                    expect(testLogStorage.toString()).toEventually(equal("error, error, error"), timeout: 6)
                    expect(testLogStorage.toString()).toEventually(equal("error, error, error, error"), timeout: 10)
                }
            }
        }
    }
}
