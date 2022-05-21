//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func filter(_ condition: @escaping (Value) -> Bool) -> EventStream<Value> {

        filter { value, date in
            
            condition(value)
        }
    }

    public func filter(_ condition: @escaping (Value, Date) -> Bool) -> EventStream<Value> {

        FilteredEventStream(
            source: self,
            condition:  { event in condition(event.value, event.time) }
        )
    }
}

class FilteredEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<Value>,
        condition: @escaping (Event<Value>) -> Bool
    ) {

        let channel = SimpleChannel<Event<Value>>()

        self.source = source

        self.sourceSubscription = source
                .subscribe(onEvent: { event in

                    if condition(event) {
                        channel.publish(event)
                    }
                })

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Value>
    private let sourceSubscription: Subscription
}
