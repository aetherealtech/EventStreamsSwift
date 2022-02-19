//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class FilterTests: XCTestCase {
    
    func testFilter() throws {
        
        let source: AnyTypedChannel<String> = SimpleChannel().asTypedChannel()
        
        let testEvents = (0..<10).map { index in "\(index)" }
        
        let filter: (String) -> Bool = { value in Int(value)!.isMultiple(of: 2) }
        
        let expectedEvents = testEvents.filter(filter)
        
        let sourceStream = source.asStream()
        let filteredStream = sourceStream.filter(filter)
        
        var receivedEvents = [String]()
        
        let subscription = filteredStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            source.publish(event)
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
