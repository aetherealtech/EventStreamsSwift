//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class FlatMapTests: XCTestCase {

    func testFlatMap() throws {
        
        let source: AnyTypedChannel<Int> = SimpleChannel().asTypedChannel()
        
        let testEvents = Array(0..<10)
        
        let innerSources: [AnyTypedChannel<String>] = testEvents.map { _ in
         
            SimpleChannel().asTypedChannel()
        }
        
        let innerStreams = innerSources.map { innerSource in
         
            EventStream<String>(channel: innerSource)
        }
        
        let transform: (Int) -> EventStream<String> = { index in
         
            innerStreams[index]
        }
                
        var expectedEvents = [String]()
        
        let sourceStream = source.asStream()
        let flatMappedStream = sourceStream.flatMap(transform)
        
        var receivedEvents = [String]()
        
        let subscription = flatMappedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            
            let innerEvents = (0..<10).map { index in
            
                "\(event)-\(index)"
            }
            
            let innerSource = innerSources[event]
            
            innerSource.publish("Shouldn't be there")
            
            source.publish(event)
            
            for innerEvent in innerEvents {
                innerSource.publish(innerEvent)
                expectedEvents.append(innerEvent)
            }
        }
        
        for (index, innerSource) in innerSources.enumerated() {
            
            for innerIndex in 0..<10 {
                
                let additionalEvent = "Additional event \(innerIndex) from source \(index)"
                innerSource.publish(additionalEvent)
                expectedEvents.append((additionalEvent))
            }
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)
    }
}
