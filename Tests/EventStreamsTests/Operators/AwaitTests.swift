//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AwaitTests: XCTestCase {
    func testAwait() async throws {
        let source = SimpleChannel<Task<Int, Never>>()
        
        let testEvents = Set<Int>(0..<10)

        let sourceStream = source.stream
        let awaitedStream = sourceStream.await()
        
        @Synchronized
        var receivedEvents = Set<Int>()
        
        let _ = awaitedStream.subscribe { [_receivedEvents] (event: Int) in
            DispatchQueue.main.async {
                _receivedEvents.wrappedValue.insert(event)
            }
        }
        
        for event in testEvents {
            source.publish(Task<Int, Never> {
                try! await Task.sleep(nanoseconds: UInt64(1e3))

                return event
            })
        }

        try await Task.sleep(nanoseconds: UInt64(1e9))

        try assertEqual(receivedEvents, testEvents)
    }
}
