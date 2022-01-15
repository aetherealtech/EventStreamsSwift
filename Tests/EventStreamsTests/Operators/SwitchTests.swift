//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class SwitchTests: XCTestCase {
 
    func testSwitch() throws {
        
        let source: AnyTypedChannel<EventStream<String>> = SimpleChannel().asTypedChannel()
        
        let testEvents = Array(0..<10)
        
        let innerSources: [AnyTypedChannel<String>] = testEvents.map { _ in
         
            SimpleChannel().asTypedChannel()
        }
        
        let innerStreams = innerSources.map { innerSource in
         
            innerSource.asStream()
        }

        var expectedEvents = [String]()
        
        let sourceStream = source.asStream()
        let switchedStream = sourceStream.switch()
        
        var receivedEvents = [String]()
        
        let subscription = switchedStream.subscribe { event in receivedEvents.append(event) }
        
        for event in testEvents {
            
            let innerEvents = (0..<10).map { index in
            
                "\(event)-\(index)"
            }
            
            let innerSource = innerSources[event]
            
            innerSource.publish("Shouldn't be there")
            
            let innerStream = innerStreams[event]
            source.publish(innerStream)
            
            for innerEvent in innerEvents {
                innerSource.publish(innerEvent)
                expectedEvents.append(innerEvent)
            }
        }
        
        var obsoleteSources = innerSources
        obsoleteSources.removeLast()
        
        for (index, innerSource) in obsoleteSources.enumerated() {
            
            for innerIndex in 0..<10 {
                
                let additionalEvent = "Additional event \(innerIndex) from source \(index)"
                innerSource.publish(additionalEvent)
            }
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)
    }
}
