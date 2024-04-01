//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Scheduling
import Synchronization

@testable import EventStreams

final class TimestampedTests: XCTestCase {
    func testTimestamped() throws {
        let source = SimpleChannel<Int>()
        
        let testValues = Array(0..<10)

        let sourceStream = source.stream
        let timestampedStream = sourceStream.timestamped
        
        @Synchronized
        var receivedEvents = [Timestamped<Int>]()
        
        let _ = timestampedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }

        var expectedTimestamps: [Range<Instant>] = []

        for value in testValues {
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.01..<0.5))

            let minDate = Instant.now
            source.publish(value)
            let maxDate = Instant.now

            expectedTimestamps.append(minDate..<maxDate)
        }
        
        try assertEqual(receivedEvents.map { event in event.value }, testValues)
        try assertTrue(receivedEvents.map { event in event.time }.elementsEqual(expectedTimestamps) { first, second in second.contains(first) })
    }
}
