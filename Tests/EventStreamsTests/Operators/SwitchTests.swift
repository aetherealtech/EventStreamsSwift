//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class SwitchTests: XCTestCase {
    func testSwitch() throws {
        let source = SimpleChannel<ChannelEventStream<SimpleChannel<String>>>()
        
        let testEvents = Array(0..<10)
        
        let innerSources: [SimpleChannel<String>] = testEvents.map { _ in
            SimpleChannel<String>()
        }
        
        let innerStreams = innerSources.map { innerSource in
            innerSource.stream
        }

        var expectedEvents = [String]()
        
        let sourceStream = source.stream
        let switchedStream = sourceStream.switch()
        
        @Synchronized
        var receivedEvents = [String]()
        
        let _ = switchedStream.subscribe { [_receivedEvents] event in _receivedEvents.wrappedValue.append(event) }
        
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
        
        try assertEqual(receivedEvents, expectedEvents)
    }
}
