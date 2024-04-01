//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class FlatMapAsyncTests: XCTestCase {
    func testFlatMapAsync() async throws {
        let source = SimpleChannel<Int>()

        let testEvents = Set<Int>(0..<10)

        let innerSources: [SimpleChannel<String>] = testEvents.map { _ in
            SimpleChannel<String>()
        }

        let innerStreams = innerSources.map { innerSource in
            innerSource.stream
        }

        let asyncTransform: @Sendable (Int) async -> ChannelEventStream<SimpleChannel<String>> = { index in
            try! await Task.sleep(nanoseconds: UInt64(1e3))

            return innerStreams[index]
        }

        var expectedEvents = Set<String>()

        let sourceStream = source.stream
        let flatMappedStream = sourceStream.flatMap(asyncTransform)
        
        @Synchronized
        var receivedEvents = Set<String>()
        
        let _ = flatMappedStream.subscribe { [_receivedEvents] (event: String) in
            DispatchQueue.main.async {
                _receivedEvents.wrappedValue.insert(event)
            }
        }

        for event in testEvents {
            let innerEvents = (0..<10).map { index in
                "\(event)-\(index)"
            }

            let innerSource = innerSources[event]

            innerSource.publish("Shouldn't be there")

            source.publish(event)

            try! await Task.sleep(nanoseconds: UInt64(1e5))

            for innerEvent in innerEvents {
                innerSource.publish(innerEvent)
                expectedEvents.insert(innerEvent)
            }
        }

        for (index, innerSource) in innerSources.enumerated() {
            for innerIndex in 0..<10 {
                let additionalEvent = "Additional event \(innerIndex) from source \(index)"
                innerSource.publish(additionalEvent)
                expectedEvents.insert((additionalEvent))
            }
        }

        try await Task.sleep(nanoseconds: UInt64(3e9))

        try assertEqual(receivedEvents, expectedEvents)
    }
}
