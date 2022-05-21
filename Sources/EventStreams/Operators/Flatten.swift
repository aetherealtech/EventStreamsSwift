//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func flatten<InnerValue>() -> EventStream<InnerValue> where Value == EventStream<InnerValue> {

        FlattenEventStream(
            source: self
        )
    }
}

class FlattenEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<EventStream<Value>>
    ) {

        let eventChannel = SimpleChannel<Event<Value>>()
        completeChannelInternal = SimpleChannel<Void>()

        self.source = source

        super.init(
            eventChannel: eventChannel,
            completeChannel: completeChannelInternal
        )

        var outerSubscription: Subscription!

        outerSubscription = source.subscribe(
            onValue: { innerStream in

                var subscription: Subscription!

                subscription = innerStream
                        .subscribe(onEvent: eventChannel.publish, onComplete: {

                            self.subscriptions.remove(subscription)
                            self.checkComplete()
                        })

                subscription
                        .store(in: &self.subscriptions)

            },
            onComplete: {

                self.subscriptions.remove(outerSubscription)
                self.checkComplete()
            }
        )

        outerSubscription
                .store(in: &subscriptions)
    }

    private func checkComplete() {

        if subscriptions.isEmpty {
            completeChannelInternal.publish()
        }
    }

    private let source: EventStream<EventStream<Value>>

    private let completeChannelInternal: SimpleChannel<Void>
    private var subscriptions = Set<Subscription>()
}
