//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class CompactMapAsyncTests: XCTestCase {
    func testCompactMapAsync() async throws {
        let source = SimpleChannel<Int>()
        
        let testEvents = Set<Int>(0..<10)

        let transform: @Sendable (Int) -> String? = { value in
            value.isMultiple(of: 3) ? "\(value)" : nil
        }

        let asyncTransform: @Sendable (Int) async -> String? = { value in
            try! await Task.sleep(nanoseconds: UInt64(1e3))
            return transform(value)
        }
        
        let expectedEvents = Set<String>(testEvents.compactMap(transform))
        
        let sourceStream = source.stream
        let mappedStream = sourceStream.compactMap(asyncTransform)
        
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
