//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func filter(_ condition: @escaping (Value) -> Bool) -> EventStream<Value> {

        FilteredEventStream(
            source: self,
            condition: condition
        )
    }
}

class FilteredEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<Value>,
        condition: @escaping (Value) -> Bool
    ) {

        let channel = SimpleChannel<Value>()

        self.source = source

        self.sourceSubscription = source
                .subscribe { value in

                    if condition(value) {
                        channel.publish(value)
                    }
                }

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Value>
    private let sourceSubscription: Subscription
}
