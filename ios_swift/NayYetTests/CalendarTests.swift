import Foundation
import XCTest
@testable import CalendarCore

final class CalendarTests: XCTestCase {
    struct Vector: Decodable { let date: String; let expected: [Int] }
    func fixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
    func testReferenceDates() throws {
        let store = try CalendarStore(data: fixture("calendar"))
        let vectors = try JSONDecoder().decode([Vector].self, from: fixture("test-vectors"))
        for vector in vectors {
            let parts = vector.date.split(separator: "-").map { Int($0)! }
            let day = try store.get(CalendarStore.date(parts[0], parts[1], parts[2]))
            XCTAssertEqual([day.year, day.month, day.day, day.yearType, day.length], vector.expected, vector.date)
        }
        XCTAssertThrowsError(try store.get(CalendarStore.first.addingTimeInterval(-86400)))
        XCTAssertThrowsError(try store.get(CalendarStore.last.addingTimeInterval(86400)))
    }
    func testYangonMidnight() {
        let before = CalendarStore.date(2026, 10, 24).addingTimeInterval(17 * 3600 + 29 * 60)
        XCTAssertEqual(CalendarStore.today(now: before), CalendarStore.date(2026, 10, 24))
        XCTAssertEqual(CalendarStore.today(now: before.addingTimeInterval(60)), CalendarStore.date(2026, 10, 25))
    }
    func testEntireRange() throws {
        let store = try CalendarStore(data: fixture("calendar"))
        var date = CalendarStore.first, count = 0
        while date <= CalendarStore.last {
            let day = try store.get(date)
            XCTAssertTrue((1...day.length).contains(day.day))
            date = date.addingTimeInterval(86400); count += 1
        }
        XCTAssertEqual(count, 73414)
        XCTAssertLessThanOrEqual(store.upcoming(CalendarStore.last).count, 1)
    }
}
