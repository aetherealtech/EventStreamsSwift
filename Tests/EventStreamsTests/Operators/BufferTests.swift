//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class BufferTests: XCTestCase {

    func testBufferOverlap() throws {
        
        let source: AnyTypedChannel<Int> = SimpleChannel().asTypedChannel()
        let sourceStream = source.asStream()
        
        let size = 10
        let stride = 7
        
        let total = size + stride*(size - 1) - 1
        let testEvents = Array(0..<total)
        
        let expectedEvents = (0..<size-1).map { index in
            
            (0..<size).map { innerIndex in
                
                index * stride + innerIndex
            }
        }

        let bufferedStream = sourceStream.buffer(count: size, stride: stride)
        
        var receivedEvents = [[Int]]()
        
        let subscription = bufferedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
    
    func testBufferGaps() throws {
        
        let source: AnyTypedChannel<Int> = SimpleChannel().asTypedChannel()
        let sourceStream = EventStream<Int>(channel: source)
        
        let size = 7
        let stride = 10
        
        let total = stride * stride
        let testEvents = Array(0..<total)
        
        let expectedEvents = (0..<stride).map { index in
            
            (0..<size).map { innerIndex in
                
                index * stride + innerIndex
            }
        }

        let bufferedStream = sourceStream.buffer(count: size, stride: stride)
        
        var receivedEvents = [[Int]]()
        
        let subscription = bufferedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
