//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class CompactMapTests: XCTestCase {
    func testCompactMap() throws {
        let source = SimpleChannel<Int>()
        
        let testEvents = Array(0..<10)
         
        let transform: @Sendable (Int) -> String? = { value in value.isMultiple(of: 3) ? "\(value)" : nil }

        let expectedEvents = testEvents.compactMap(transform)
        
        let sourceStream = source.stream
        let compactedStream = sourceStream.compactMap(transform)
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = compactedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
