//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class MapAsyncTests: XCTestCase {
    func testMapAsync() async throws {
        let source = SimpleChannel<Int>()
        
        let testEvents = Set<Int>(0..<10)
        
        let transform: @Sendable (Int) -> String = { value in
            "\(value)"
        }

        let asyncTransform: @Sendable (Int) async -> String = { value in
            try! await Task.sleep(nanoseconds: UInt64(1e3))
            return transform(value)
        }
        
        let expectedEvents = Set<String>(testEvents.map(transform))
        
        let sourceStream = source.stream
        let mappedStream = sourceStream.map(asyncTransform)
        
        @Synchronized
        var receivedEvents = Set<String>()
        
        let _ = mappedStream.subscribe { [_receivedEvents] (event: String) in
            DispatchQueue.main.async {
                _receivedEvents.wrappedValue.insert(event)
            }
        }
        
        for event in testEvents {
            source.publish(event)
        }

        try await Task.sleep(nanoseconds: UInt64(1e9))

        try assertEqual(receivedEvents, expectedEvents)
    }
}
