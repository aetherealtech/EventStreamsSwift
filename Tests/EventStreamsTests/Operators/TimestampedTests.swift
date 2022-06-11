//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
import CoreExtensions

@testable import EventStreams

typealias DateRange = Range<Date>

class TimestampedTests: XCTestCase {

    func testTimestamped() throws {
        
        let source = SimpleChannel<Int>()
        
        let testValues = Array(0..<10)

        let sourceStream = source.asStream()
        let timestampedStream = sourceStream.timestamped()
        
        var receivedEvents = [Timestamped<Int>]()
        
        let subscription = timestampedStream.subscribe { event in receivedEvents.append(event) }

        var expectedTimestamps: [DateRange] = []

        for value in testValues {
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.01..<0.5))

            let minDate = Date()
            source.publish(value)
            let maxDate = Date()

            expectedTimestamps.append(minDate..<maxDate)
        }
        
        XCTAssertEqual(receivedEvents.map { event in event.value }, testValues)
        XCTAssertTrue(receivedEvents.map { event in event.time }.elementsEqual(expectedTimestamps) { first, second in second.contains(first) })

        withExtendedLifetime(subscription) { }
    }
}
