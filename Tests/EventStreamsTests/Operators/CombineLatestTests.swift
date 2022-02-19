//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class CombineLatestTests: XCTestCase {

    func testCombineLatest() throws {
        
        typealias Combined = (String, String, String, String, String)
        
        let sources: [AnyTypedChannel<String>] = (0..<5).map { _ in
            
            SimpleChannel().asTypedChannel()
        }
        
        let sourceStreams = sources.map { source in

            source.asStream()
        }

        var expectedEvents = [Combined]()
        
        let combinedStream = sourceStreams[0]
            .combineLatest(sourceStreams[1], sourceStreams[2], sourceStreams[3], sourceStreams[4])
        
        var receivedEvents = [Combined]()
        
        let subscription = combinedStream.subscribe { event in receivedEvents.append(event) }
        
        for (index, source) in sources.enumerated() {
            
            source.publish("Initial \(index)");
        }
        
        expectedEvents.append(("Initial 0", "Initial 1", "Initial 2", "Initial 3", "Initial 4"))
        
        sources[0].publish("Next 0")
        expectedEvents.append(("Next 0", "Initial 1", "Initial 2", "Initial 3", "Initial 4"))

        sources[1].publish("Next 1")
        expectedEvents.append(("Next 0", "Next 1", "Initial 2", "Initial 3", "Initial 4"))
        
        sources[2].publish("Next 2")
        expectedEvents.append(("Next 0", "Next 1", "Next 2", "Initial 3", "Initial 4"))
    
        sources[3].publish("Next 3")
        expectedEvents.append(("Next 0", "Next 1", "Next 2", "Next 3", "Initial 4"))
        
        sources[4].publish("Next 4")
        expectedEvents.append(("Next 0", "Next 1", "Next 2", "Next 3", "Next 4"))

        XCTAssertTrue(receivedEvents.elementsEqual(expectedEvents, by: { first, second in
            
            first.0 == second.0 &&
            first.1 == second.1 &&
            first.2 == second.2 &&
            first.3 == second.3 &&
            first.4 == second.4
        }))

        withExtendedLifetime(subscription) { }
    }
    
    func testCombineLatestArray() throws {
                
        let sources: [AnyTypedChannel<String>] = (0..<10).map { _ in
            
            SimpleChannel().asTypedChannel()
        }
        
        let sourceStreams = sources.map { source in

            source.asStream()
        }

        var expectedEvents = [[String]]()
        
        let combinedStream = sourceStreams.combineLatest()

        var receivedEvents = [[String]]()
        
        let subscription = combinedStream.subscribe { event in receivedEvents.append(event) }
        
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
            
            expectedEvents.append(nextEvent)
        }

        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
