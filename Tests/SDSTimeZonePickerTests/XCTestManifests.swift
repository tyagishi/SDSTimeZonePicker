import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SDSTimeZonePickerTests.allTests),
    ]
}
#endif
