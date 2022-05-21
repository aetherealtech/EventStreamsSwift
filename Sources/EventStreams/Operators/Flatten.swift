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

        self.source = source

        super.init(
            channel: eventChannel
        )

        var outerSubscription: Subscription!

        outerSubscription = source.subscribe(
            onValue: { innerStream in

                var subscription: Subscription!

                subscription = innerStream
                        .subscribe(
                            onEvent: eventChannel.publish
                        )

                subscription
                        .store(in: &self.subscriptions)

            }
        )

        outerSubscription
                .store(in: &subscriptions)
    }

    private let source: EventStream<EventStream<Value>>

    private var subscriptions = Set<Subscription>()
}
