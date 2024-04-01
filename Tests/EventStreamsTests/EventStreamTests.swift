//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class EventStreamTests: XCTestCase {
    func testPublish() throws {
        let source = SimpleChannel<String>()

        let stream = source
            .stream

        @Synchronized
        var receivedValue1: String?
        
        @Synchronized
        var receivedValue2: String?

        let _ = stream.subscribe { [_receivedValue1] value in _receivedValue1.wrappedValue = value }
        let _ = stream.subscribe { [_receivedValue2] value in _receivedValue2.wrappedValue = value }

        let testValue = "SomeTestValue"

        source.publish(testValue)

        try assertEqual(receivedValue1, testValue)
        try assertEqual(receivedValue2, testValue)
    }

    func testUnsubscribe() throws {
        let source = SimpleChannel<String>()

        let stream = source
            .stream

        @Synchronized
        var receivedValue1: String?
        
        @Synchronized
        var receivedValue2: String?

        let _ = stream.subscribe { [_receivedValue1] value in _receivedValue1.wrappedValue = value }
        let subscription = stream.subscribe { [_receivedValue2] value in _receivedValue2.wrappedValue = value }

        let testValue = "SomeTestValue"

        subscription.cancel()

        source.publish(testValue)

        try assertEqual(receivedValue1, testValue)
        try assertNil(receivedValue2)
    }
}
