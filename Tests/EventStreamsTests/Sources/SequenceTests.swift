//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling
import Observer

@testable import EventStreams

class SequenceTests: XCTestCase {

    func testSequence() throws {

        let startTime = Date()
        let interval = TimeInterval.random(in: 10.0..<100.0)

        let testEvents = (0..<10).map { index -> (Int, Date) in

            let time = startTime.addingTimeInterval(interval * TimeInterval(index))

            return (index, time: time)
        }

        let scheduler = MockScheduler()

        let stream = EventStream<Int>.sequence(
            values: testEvents,
            on: scheduler
        )

        var receivedValues: [Int] = []

        let subscription = stream.subscribe { value in

            receivedValues.append(value)
        }

        XCTAssertEqual(receivedValues, [])

        scheduler.process()

        XCTAssertEqual(receivedValues, testEvents.map { event in event.0 })
        XCTAssertEqual(scheduler.runAtInvocations.count, testEvents.count)

        for (invocation, testEvent) in zip(scheduler.runAtInvocations, testEvents) {

            XCTAssertEqual(invocation.time, testEvent.1)
        }

        withExtendedLifetime(subscription) { }
    }
}
