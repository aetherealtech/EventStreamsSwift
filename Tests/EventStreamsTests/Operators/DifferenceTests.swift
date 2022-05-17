//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class DifferenceTests: XCTestCase {

    func testDifference() throws {
        
        let source = SimpleChannel<Int>()
        let sourceStream = source.asStream()
        
        let testEvents = (0..<15).map { value in (value * value) + 2 }
        
        let expectedEvents = testEvents.indices
            .filter { index in index < testEvents.count - 1 }
            .map { index in testEvents[index + 1] - testEvents[index] }

        let differentiatedStream = sourceStream.difference(-)
        
        var receivedEvents = [Int]()
        
        let subscription = differentiatedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
