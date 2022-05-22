//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func `switch`<InnerValue>() -> EventStream<InnerValue> where Value == EventStream<InnerValue> {

        SwitchEventStream(
            source: self
        )
    }
}

class SwitchEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<EventStream<Value>>
    ) {

        let eventChannel = SimpleChannel<Event<Value>>()

        self.source = source

        super.init(
            channel: eventChannel
        )

        outerSubscription = source.subscribe(
            onValue: { innerStream in

                self.innerSource = innerStream

                self.innerSubscription = innerStream
                        .subscribe(
                            onEvent: eventChannel.publish
                        )

            }
        )
    }

    private let source: EventStream<EventStream<Value>>
    private var innerSource: EventStream<Value>?

    private var outerSubscription: Subscription! = nil
    private var innerSubscription: Subscription! = nil
}
