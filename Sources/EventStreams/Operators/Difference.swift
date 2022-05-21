//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func difference<Result>(
        _ differentiator: @escaping (Value, Value) -> Result
    ) -> EventStream<Result> {

        DifferenceEventStream(
            source: self,
            differentiator: differentiator
        )
    }
}

class DifferenceEventStream<Value, Result> : EventStream<Result>
{
    init(
        source: EventStream<Value>,
        differentiator: @escaping (Value, Value) -> Result
    ) {

        self.source = source

        var lastOpt: Value?

        let channel = SimpleChannel<Event<Result>>()

        self.subscription = source.subscribe(
            onValue: { value in

                if let last = lastOpt {
                    channel.publish(differentiator(value, last))
                }

                lastOpt = value
            }
        )

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Value>

    private let subscription: Subscription
}
