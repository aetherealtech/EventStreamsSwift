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

        let scheduler = MockScheduler()

        let stream = EventStream.just(
            testValue,
            at: testTime,
            on: scheduler
        )

        var receivedValue: Int? = nil

        let subscription = stream.subscribe { value in

            receivedValue = value
        }

        XCTAssertNil(receivedValue)
        XCTAssertEqual(scheduler.runAtInvocations.count, 1)
        XCTAssertEqual(scheduler.runAtInvocations[0].time, testTime)
        
        scheduler.process()
        
        XCTAssertEqual(receivedValue, testValue)

        withExtendedLifetime(subscription) { }
    }
}
