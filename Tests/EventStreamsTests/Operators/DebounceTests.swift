//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class DebounceTests: XCTestCase {

    func testDebounce() throws {
        
        let source: AnyTypedChannel<String> = SimpleChannel().asTypedChannel()
        let sourceStream = source.asStream()
         
        var expectedEvents = [String]()

        let tolerance: TimeInterval = 0.25
        let debouncedStream = sourceStream.debounce(tolerance: tolerance)
        
        var receivedEvents = [String]()
        
        let subscription = debouncedStream.subscribe { event in receivedEvents.append(event) }
        
        for index in 0..<10 {
            
            let firstEvent = "Event \(index)"
            let secondEvent = "Echo \(index)"

            source.publish(firstEvent)
            source.publish(secondEvent)
            
            expectedEvents.append(firstEvent)
            
            Thread.sleep(forTimeInterval: tolerance)
        }

        XCTAssertEqual(receivedEvents, expectedEvents)
    }
}
