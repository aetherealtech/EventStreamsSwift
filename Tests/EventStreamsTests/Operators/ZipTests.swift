//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class ZipTests: XCTestCase {
    func testZip() throws {
        typealias Combined = (String, String, String, String, String)
        
        let sources: [SimpleChannel<String>] = (0..<5).map { _ in
            SimpleChannel<String>()
        }
        
        let sourceStreams = sources.map { source in
            source.stream
        }

        var expectedEvents = [Combined]()
        
        let zippedStream = sourceStreams[0]
            .zip(sourceStreams[1], sourceStreams[2], sourceStreams[3], sourceStreams[4])
        
        @Synchronized
        var receivedEvents = [Combined]()
        
        let _ = zippedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for (index, source) in sources.enumerated() {
            source.publish("Initial \(index)");
        }
        
        expectedEvents.append(("Initial 0", "Initial 1", "Initial 2", "Initial 3", "Initial 4"))
        
        for (index, source) in sources.enumerated() {
            source.publish("Next \(index)");
        }
        
        expectedEvents.append(("Next 0", "Next 1", "Next 2", "Next 3", "Next 4"))

        try assertTrue(receivedEvents.elementsEqual(expectedEvents, by: { first, second in
            first.0 == second.0 &&
            first.1 == second.1 &&
            first.2 == second.2 &&
            first.3 == second.3 &&
            first.4 == second.4
        }))
    }
    
    func testZipArray() throws {
        let sources: [SimpleChannel<String>] = (0..<10).map { _ in
            SimpleChannel<String>()
        }
        
        let sourceStreams = sources.map { source in
            source.stream
        }

        var expectedEvents = [[String]]()
        
        let zippedStream = sourceStreams.zip()
        
        @Synchronized
        var receivedEvents = [[String]]()
        
        let _ = zippedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for (index, source) in sources.enumerated() {
            source.publish("Initial \(index)");
        }
        
        let initialEvent = sources.indices.map { index in "Initial \(index)"}
        expectedEvents.append(initialEvent)

        var nextEvent = initialEvent
        
        for index in sources.indices {
            let value = "Next \(index)"
            
            sources[index].publish(value)
            nextEvent[index] = value
        }
        
        expectedEvents.append(nextEvent)
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
