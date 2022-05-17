//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class AccumulateTests: XCTestCase {

    func testAccumulate() throws {
        
        let source = SimpleChannel<Int>()
        let sourceStream = source.asStream()
        
        let testEvents = Array(0..<15)
        let expectedEvents = testEvents.reduce(into: []) { partialResult, next in
            
            partialResult.append((partialResult.last ?? 0) + next)
        }

        let accumulatedStream = sourceStream.accumulate(initialValue: 0, +)
        
        var receivedEvents = [Int]()
        
        let subscription = accumulatedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
