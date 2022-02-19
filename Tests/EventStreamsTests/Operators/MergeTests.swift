//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class MergeTests: XCTestCase {

    func testMerge() throws {
        
        let sources: [AnyTypedChannel<Int>] = (0..<5).map { _ in
            
            SimpleChannel().asTypedChannel()
        }
        
        let sourceStreams = sources.map { source in

            source.asStream()
        }
        
        let testEvents = sources.indices.map { index in
            
            Array(0..<10).map { innerIndex in index * 20 + innerIndex }
        }

        var expectedEvents = [Int]()
        
        let mergedStream = sourceStreams.merge()
        
        var receivedEvents = [Int]()
        
        let subscription = mergedStream.subscribe { event in receivedEvents.append(event) }
        
        for index in 0..<testEvents.flatMap({ events in events }).count {
            
            let outerIndex = index % testEvents.count
            let innerIndex = index / testEvents.count
            
            let source = sources[outerIndex]
            let event = testEvents[outerIndex][innerIndex]
            
            source.publish(event)
            expectedEvents.append(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
