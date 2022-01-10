//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class CompactMapTests: XCTestCase {

    func testCompactMap() throws {
        
        let source: AnyTypedChannel<Int> = SimpleChannel().asTypedChannel()
        
        let testEvents = Array(0..<10)
         
        let transform: (Int) -> String? = { value in value.isMultiple(of: 3) ? "\(value)" : nil }

        let expectedEvents = testEvents.compactMap(transform)
        
        let sourceStream = EventStream<Int>(source: source)
        let compactedStream = sourceStream.compactMap(transform)
        
        var receivedEvents = [String]()
        
        let subscription = compactedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)
    }
}
