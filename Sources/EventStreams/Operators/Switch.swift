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
            eventChannel: eventChannel,
            completeChannel: completeChannelInternal
        )

        outerSubscription = source.subscribe(
            onValue: { innerStream in

                self.innerSubscription = innerStream
                        .subscribe(onEvent: eventChannel.publish, onComplete: {

                            self.innerSubscription = nil
                            self.checkComplete()
                        })

            },
            onComplete: {

                self.outerSubscription = nil
                self.checkComplete()
            }
        )
    }

    private func checkComplete() {

        if outerSubscription == nil && innerSubscription == nil {
            completeChannelInternal.publish()
        }
    }

    private let source: EventStream<EventStream<Value>>

    private let completeChannelInternal = SimpleChannel<Void>()

    private var outerSubscription: Subscription! = nil
    private var innerSubscription: Subscription! = nil
}
