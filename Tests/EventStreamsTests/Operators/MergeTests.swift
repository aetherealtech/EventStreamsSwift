//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class MergeTests: XCTestCase {
    func testMerge() throws {
        let sources: [SimpleChannel<Int>] = (0..<5).map { _ in
            SimpleChannel<Int>()
        }
        
        let sourceStreams = sources.map { source in
            source.stream
        }
        
        let testEvents = sources.indices.map { index in
            Array(0..<10).map { innerIndex in index * 20 + innerIndex }
        }

        var expectedEvents = [Int]()
        
        let mergedStream = sourceStreams.merge()
        
        @Synchronized
        var receivedEvents = [Int]()
        
        let _ = mergedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for index in 0..<testEvents.flatMap({ events in events }).count {
            let outerIndex = index % testEvents.count
            let innerIndex = index / testEvents.count
            
            let source = sources[outerIndex]
            let event = testEvents[outerIndex][innerIndex]
            
            source.publish(event)
            expectedEvents.append(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
