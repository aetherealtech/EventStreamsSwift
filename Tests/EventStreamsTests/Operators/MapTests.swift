//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class MapTests: XCTestCase {
    func testMap() throws {
        let source = SimpleChannel<Int>()
        
        let testEvents = Array(0..<10)
        
        let transform: @Sendable (Int) -> String = { value in "\(value)" }
        
        let expectedEvents = testEvents.map(transform)
        
        let sourceStream = source.stream
        let mappedStream = sourceStream.map(transform)
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = mappedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
