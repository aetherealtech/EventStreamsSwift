import Assertions
import Scheduling
import SchedulingTestUtilities
import Synchronization
import XCTest

@testable import EventStreams

final class TimerTests: XCTestCase {
    func testSchedule() throws {
        for _ in 0..<100 {
            let fireDates = (0..<10).map { index in
                Instant.now + (8.5 * Double(index)).seconds
            }
            
            @Synchronized
            var workInvocations = 0

            let scheduler = MockScheduler()

            @Synchronized
            var completedAfterInvocations: Int? = nil

            let timer = scheduler.timer(
                at: fireDates
            )
            
            _ = timer.subscribe { [_workInvocations] in
                _workInvocations.wrappedValue += 1
            }
            
            scheduler.process()

            try assertTrue(scheduler.runAtInvocations.elementsEqual(fireDates, by: { invocation, expectedFireTime in
                invocation.time == expectedFireTime
            }))
            
            try assertEqual(workInvocations, fireDates.count)
            try assertEqual(completedAfterInvocations, workInvocations)
        }
    }
    
    func testCancel() throws {
        for _ in 0..<100 {
            let fireDates = (0..<10).map { index in
                Instant.now + (8.5 * Double(index)).seconds
            }
            
            let invocationsCount = Int.random(in: fireDates.indices)
            
            @Synchronized
            var workInvocations = 0

            let scheduler = MockScheduler()

            @Synchronized
            var completedAfterInvocations: Int? = nil
  
            @Synchronized
            var timer: EventStreams.Timer<MockScheduler>! = nil

            timer = scheduler.timer(
                at: fireDates
            )
            
            _ = timer.subscribe { [_workInvocations, _timer] in
                _workInvocations.write { workInvocations in
                    if workInvocations == invocationsCount {
                        _timer.wrappedValue = nil
                        return
                    }
                    
                    workInvocations += 1
                }
            }
            
            scheduler.process()

            try assertEqual(workInvocations, invocationsCount)
            try assertEqual(completedAfterInvocations, workInvocations)
        }
    }
}
