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

        let channel = SimpleChannel<Value>()

        self.sources = sources

        super.init(
            channel: channel
        )

        for source in sources {

            source
                .subscribe(channel.publish)
                .store(in: &subscriptions)
        }
    }

    private let sources: SourceCollection

    private var subscriptions = Set<Subscription>()
}
