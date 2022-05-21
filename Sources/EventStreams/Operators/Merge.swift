//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension Collection {

    public func merge<Value>() -> EventStream<Value> where Element == EventStream<Value> {

        MergeEventStream(
            sources: self
        )
    }
}

extension EventStream {

    public func merge(_ other: EventStream<Value>) -> EventStream<Value> {

        [self, other].merge()
    }
}

class MergeEventStream<Value, SourceCollection: Collection> : EventStream<Value> where SourceCollection.Element == EventStream<Value>
{
    init(
        sources: SourceCollection
    ) {

        let channel = SimpleChannel<Event<Value>>()

        self.sources = sources

        super.init(
            eventChannel: channel,
            completeChannel: completeChannelInternal
        )

        for source in sources {

            var subscription: Subscription!

            subscription = source.subscribe(
                onEvent: channel.publish,
                onComplete: {

                    self.subscriptions.remove(subscription)
                    self.checkComplete()
                }
            )

            subscription
                    .store(in: &subscriptions)
        }
    }

    private let sources: SourceCollection
    private let completeChannelInternal = SimpleChannel<Void>()

    private var subscriptions = Set<Subscription>()

    private func checkComplete() {

        if subscriptions.isEmpty {
            completeChannelInternal.publish()
        }
    }
}
