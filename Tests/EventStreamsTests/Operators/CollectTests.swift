//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class CollectTests: XCTestCase {
    func testCollectOverlap() throws {
        let source = SimpleChannel<Int>()
        let sourceStream = source.stream
        
        let size = 10
        let stride = 7
        
        let total = size + stride*(size - 1) - 1
        let testEvents = Array(0..<total)
        
        let expectedEvents = (0..<size-1).map { index in
            (0..<size).map { innerIndex in
                index * stride + innerIndex
            }
        }

        let collectedStream = sourceStream
            .collect(count: size, stride: stride)
        
        @Synchronized
        var receivedEvents = [[Int]]()
        
        let _ = collectedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
    
    func testCollectGaps() throws {
        let source = SimpleChannel<Int>()
        let sourceStream = source.stream
        
        let size = 7
        let stride = 10
        
        let total = stride * stride
        let testEvents = Array(0..<total)
        
        let expectedEvents = (0..<stride).map { index in
            (0..<size).map { innerIndex in
                index * stride + innerIndex
            }
        }

        let collectedStream = sourceStream.collect(count: size, stride: stride)
    
        @Synchronized
        var receivedEvents = [[Int]]()
        
        let _ = collectedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }

        for event in testEvents {
            source.publish(event)
        }
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
