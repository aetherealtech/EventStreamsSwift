//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

public func just<Value: Sendable, Scheduler: Scheduling.Scheduler>(
    _ value: Value,
    at time: Instant,
    on scheduler: Scheduler = DispatchQueue.global()
) -> Just<Value, Scheduler> {
    .init(
        value,
        at: time,
        on: scheduler
    )
}

public func just<Value: Sendable, Scheduler: Scheduling.Scheduler>(
    _ value: Value,
    after delay: Duration,
    on scheduler: Scheduler = DispatchQueue.global()
) -> Just<Value, Scheduler> {
    just(
        value,
        at: .now + delay,
        on: scheduler
    )
}

public struct Just<Value: Sendable, Scheduler: Scheduling.Scheduler>: EventStream {
    public init(
        _ value: Value,
        at time: Instant,
        on scheduler: Scheduler
    ) {
        self.value = value
        self.time = time
        self.scheduler = scheduler
        
        scheduler.run(at: time) { [channel] in
            channel.publish(value)
        }
    }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    public let value: Value
    public let time: Instant
    public let scheduler: Scheduler
    
    private let channel = SimpleChannel<Value>()
}
