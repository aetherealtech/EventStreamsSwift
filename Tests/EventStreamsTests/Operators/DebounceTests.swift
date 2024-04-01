//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Scheduling
import Synchronization

@testable import EventStreams

final class DebounceTests: XCTestCase {
    func testDebounce() throws {
        let source = SimpleChannel<String>()
        let sourceStream = source.stream
         
        var expectedEvents = [String]()

        let tolerance = 0.25.seconds
        let debouncedStream = sourceStream.debounce(tolerance: tolerance)
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = debouncedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for index in 0..<10 {
            let firstEvent = "Event \(index)"
            let secondEvent = "Echo \(index)"

            source.publish(firstEvent)
            source.publish(secondEvent)
            
            expectedEvents.append(firstEvent)
            
            Thread.sleep(forTimeInterval: tolerance / 1.seconds)
        }

        try assertEqual(receivedEvents, expectedEvents)
    }
}
