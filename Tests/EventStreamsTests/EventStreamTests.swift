//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

class EventStreamTests: XCTestCase {

    func testPublish() throws {

        let source = SimpleChannel<String>()

        let stream = source
            .asStream()

        var receivedValue1: String?
        var receivedValue2: String?

        let subscription1 = stream.subscribe { value in receivedValue1 = value }
        let subscription2 = stream.subscribe { value in receivedValue2 = value }

        let testValue = "SomeTestValue"

        source.publish(testValue)

        XCTAssertEqual(receivedValue1, testValue)
        XCTAssertEqual(receivedValue2, testValue)

        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
    }

    func testUnsubscribe() throws {

        let source = SimpleChannel<String>()

        let stream = source
            .asStream()

        var receivedValue1: String?
        var receivedValue2: String?

        let subscription1 = stream.subscribe { value in receivedValue1 = value }
        var subscription2: Subscription? = stream.subscribe { value in receivedValue2 = value }

        let testValue = "SomeTestValue"

        subscription2 = nil

        source.publish(testValue)

        XCTAssertEqual(receivedValue1, testValue)
        XCTAssertNil(receivedValue2)

        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
    }

    func testRetain() throws {

        let source = SimpleChannel<String>()

        var stream: EventStream<String>? = source
            .asStream()

        var receivedValue: String?

        let subscription = stream?.subscribe { value in receivedValue = value }

        stream = nil

        let testValue = "SomeTestValue"

        source.publish(testValue)

        XCTAssertEqual(receivedValue, testValue)

        withExtendedLifetime(subscription) { }
    }
}
