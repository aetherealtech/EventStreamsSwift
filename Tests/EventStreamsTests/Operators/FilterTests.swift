//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class FilterTests: XCTestCase {
    func testFilter() throws {
        let source = SimpleChannel<String>()
        
        let testEvents = (0..<10).map { index in "\(index)" }
        
        let filter: @Sendable (String) -> Bool = { value in Int(value)!.isMultiple(of: 2) }
        
        let expectedEvents = testEvents.filter(filter)
        
        let sourceStream = source.stream
        let filteredStream = sourceStream.filter(filter)
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = filteredStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
