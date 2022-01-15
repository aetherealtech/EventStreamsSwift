//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling
import Observer

@testable import EventStreams

class SequenceTests: XCTestCase {

    func testSequence() throws {

        let testValue = Int.random(in: 0..<100)

        let startTime = Date()
        let interval = TimeInterval.random(in: 10.0..<100.0)

        let testEvents = (0..<10).map { index -> Event<Int> in

            let time = startTime.addingTimeInterval(interval * TimeInterval(index))

            return Event(index, time: time)
        }

        let scheduler = MockScheduler()

        let stream = EventStream<Int>.sequence(
            values: testEvents,
            on: scheduler
        )

        var receivedEvents: [Event<Int>] = []

        let subscription = stream.subscribe { event in

            receivedEvents.append(event)
        }

        XCTAssertEqual(receivedEvents, [])

        scheduler.process()

        XCTAssertEqual(receivedEvents, testEvents)
        XCTAssertEqual(scheduler.runAtInvocations.count, testEvents.count)

        for (invocation, testEvent) in zip(scheduler.runAtInvocations, testEvents) {

            XCTAssertEqual(invocation.time, testEvent.time)
        }
    }
}
