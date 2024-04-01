//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class DifferenceTests: XCTestCase {
    func testDifference() throws {
        let source = SimpleChannel<Int>()
        let sourceStream = source.stream
        
        let testEvents = (0..<15).map { value in (value * value) + 2 }
        
        let expectedEvents = testEvents.indices
            .filter { index in index < testEvents.count - 1 }
            .map { index in testEvents[index + 1] - testEvents[index] }

        let differentiatedStream = sourceStream.difference(-)
        
        @Synchronized
        var receivedEvents = [Int]()
        
        let _ = differentiatedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
