import Foundation
import Observer
import Scheduling
import Synchronization

public extension Scheduler {
    func timer(
        at fireTimes: some Sequence<Instant>
    ) -> Timer<Self> {
        .init(
            scheduler: self,
            fireTimes: fireTimes
        )
    }
}

public final class Timer<
    Scheduler: Scheduling.Scheduler
>: EventStream {
    public init<
        FireTimes: Sequence<Instant>
    >(
        scheduler: Scheduler,
        fireTimes: FireTimes
    ) {
        @Synchronized
        var fireTimeIterator = fireTimes.makeIterator()

        self.scheduler = scheduler
        self.nextFireTime = { [_fireTimeIterator] in _fireTimeIterator.wrappedValue.next() }
        
        scheduleNext()
    }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (()) -> Void
    ) -> SimpleChannel<Void>.Subscription {
        channel.subscribe(onValue)
    }

    private func scheduleNext() {
        guard let fireTime = nextFireTime() else {
            return
        }
        
        scheduler.run(at: fireTime) { [weak self] in
            guard let self else {
                return
            }
            
            self.channel.publish()
            self.scheduleNext()
        }
    }
    
    public let scheduler: Scheduler
        
    private let nextFireTime: @Sendable () -> Instant?
    private let channel = SimpleChannel<Void>()
}
