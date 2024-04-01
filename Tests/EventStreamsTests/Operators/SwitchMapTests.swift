//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class SwitchMapTests: XCTestCase {
    func testSwitchMap() throws {
        let source = SimpleChannel<Int>()
        
        let testEvents = Array(0..<10)
        
        let innerSources: [SimpleChannel<String>] = testEvents.map { _ in
            SimpleChannel<String>()
        }
        
        let innerStreams = innerSources.map { innerSource in
            innerSource.stream
        }
        
        let transform: @Sendable (Int) -> ChannelEventStream<SimpleChannel<String>> = { index in
            innerStreams[index]
        }
                
        var expectedEvents = [String]()
        
        let sourceStream = source.stream
        let switchMappedStream = sourceStream.switchMap(transform)
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = switchMappedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
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
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
