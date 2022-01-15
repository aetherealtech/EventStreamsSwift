//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Scheduling

@testable import EventStreams

class JustTests: XCTestCase {

    func testJust() throws {

        let testValue = Int.random(in: 0..<100)
        let testTime = Date().addingTimeInterval(TimeInterval.random(in: 10.0..<100.0))

        let testEvent = Event(testValue, time: testTime)

        let scheduler = MockScheduler()

        let stream = EventStream.just(
            testEvent,
            on: scheduler
        )

        var receivedEvent: Event<Int>? = nil

        let subscription = stream.subscribe { event in

            receivedEvent = event
        }

        XCTAssertNil(receivedEvent)
        XCTAssertEqual(scheduler.runAtInvocations.count, 1)
        XCTAssertEqual(scheduler.runAtInvocations[0].time, testEvent.time)
        
        scheduler.process()
        
        XCTAssertEqual(receivedEvent, testEvent)
    }
}
