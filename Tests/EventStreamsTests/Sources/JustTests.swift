//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Scheduling
import SchedulingTestUtilities
import Synchronization

@testable import EventStreams

final class JustTests: XCTestCase {
    func testJust() throws {
        let testValue = Int.random(in: 0..<100)
        let testTime = Instant.now + Double.random(in: 10..<100.0).seconds

        let scheduler = MockScheduler()

        let stream = EventStreams.just(
            testValue,
            at: testTime,
            on: scheduler
        )
        
        @Synchronized
        var receivedValue: Int? = nil

        let _ = stream.subscribe { [_receivedValue] value in
            _receivedValue.wrappedValue = value
        }

        try assertNil(receivedValue)
        try assertEqual(scheduler.runAtInvocations.count, 1)
        try assertEqual(scheduler.runAtInvocations[0].time, testTime)
        
        scheduler.process()
        
        try assertEqual(receivedValue, testValue)
    }
}
