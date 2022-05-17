//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class CompactTests: XCTestCase {

    func testCompact() throws {
        
        let source = SimpleChannel<Int?>()
        
        let testEvents = [
            0,
            1,
            nil,
            3,
            nil,
            nil,
            6,
            7,
            nil,
            9
        ]
                
        let expectedEvents = testEvents.compact()
        
        let sourceStream = source.asStream()
        let compactedStream = sourceStream.compact()
        
        var receivedEvents = [Int]()
        
        let subscription = compactedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
