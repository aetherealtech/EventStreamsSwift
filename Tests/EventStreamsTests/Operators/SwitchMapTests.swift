//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class SwitchMapTests: XCTestCase {

    func testSwitchMap() throws {
        
        let source = SimpleChannel<Int>()
        
        let testEvents = Array(0..<10)
        
        let innerSources: [SimpleChannel<String>] = testEvents.map { _ in
         
            SimpleChannel<String>()
        }
        
        let innerStreams = innerSources.map { innerSource in
         
            innerSource.asStream()
        }
        
        let transform: (Int) -> EventStream<String> = { index in
         
            innerStreams[index]
        }
                
        var expectedEvents = [String]()
        
        let sourceStream = source.asStream()
        let switchMappedStream = sourceStream.switchMap(transform)
        
        var receivedEvents = [String]()
        
        let subscription = switchMappedStream.subscribe { event in receivedEvents.append(event) }
        
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
        
        var obsoleteSources = innerSources
        obsoleteSources.removeLast()
        
        for (index, innerSource) in obsoleteSources.enumerated() {
            
            for innerIndex in 0..<10 {
                
                let additionalEvent = "Additional event \(innerIndex) from source \(index)"
                innerSource.publish(additionalEvent)
            }
        }
        
        XCTAssertEqual(receivedEvents, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
