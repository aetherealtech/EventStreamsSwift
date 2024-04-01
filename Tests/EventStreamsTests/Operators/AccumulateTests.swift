//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class AccumulateTests: XCTestCase {
    func testAccumulate() throws {
        let source = SimpleChannel<Int>()
        let sourceStream = source.stream
        
        let testEvents = Array(0..<15)
        let expectedEvents = testEvents.reduce(into: []) { partialResult, next in
            partialResult.append((partialResult.last ?? 0) + next)
        }

        let accumulatedStream = sourceStream.accumulate(initialValue: 0, +)
        
        @Synchronized
        var receivedEvents = [Int]()
        
        let _ = accumulatedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
