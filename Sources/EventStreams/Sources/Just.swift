//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension EventStream {

    public static func just(
        _ event: Event<Value>,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> {

        let channel = SimpleChannel<Event<Value>>()

        scheduler.run(at: event.time) {

            channel.publish(event)
        }

        return EventStream(
            channel: channel
        )
    }
    
    public static func just(
        _ value: Value,
        at time: Date,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> {

        just(
            Event<Value>(value, time: time),
            on: scheduler
        )
    }
    
    public static func just(
        _ value: Value,
        after delay: TimeInterval,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> {

        just(
            value,
            at: Date().addingTimeInterval(delay),
            on: scheduler
        )
    }
}
