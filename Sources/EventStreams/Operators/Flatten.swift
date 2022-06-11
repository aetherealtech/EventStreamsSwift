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

        let eventChannel = SimpleChannel<Value>()

        self.source = source

        super.init(
            channel: eventChannel
        )

        source
            .subscribe { innerStream in

                self.innerStreams.append(innerStream)

                innerStream
                    .subscribe(eventChannel.publish)
                    .store(in: &self.subscriptions)

            }
            .store(in: &subscriptions)
    }

    private let source: EventStream<EventStream<Value>>

    private var innerStreams = [EventStream<Value>]()
    private var subscriptions = Set<Subscription>()
}
