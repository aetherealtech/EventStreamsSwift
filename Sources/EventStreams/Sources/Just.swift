//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension EventStream {

    public static func just(
        _ value: Value,
        at time: Date,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> {

        let channel = SimpleChannel<Value>()

        scheduler.run(at: time) {

            channel.publish(value)
        }

        return EventStream(
            channel: channel
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
