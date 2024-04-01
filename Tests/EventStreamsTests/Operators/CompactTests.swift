//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class CompactTests: XCTestCase {
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
        
        let sourceStream = source.stream
        let compactedStream = sourceStream.compact()
        
        @Synchronized
        var receivedEvents = [Int]()
        
        let _ = compactedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
