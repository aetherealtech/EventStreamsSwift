//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

public extension EventStream where Value: EventStream {
    func flatten() -> FlattenEventStream<Self> {
        .init(
            source: self
        )
    }
}

public struct FlattenEventStream<Source: EventStream>: EventStream where Source.Value: EventStream {
    init(
        source: Source
    ) {
        self.source = source

        source
            .subscribe { [channel, _innerStreams, _subscriptions] innerStream in
                _innerStreams.wrappedValue.append(innerStream)

                innerStream
                    .subscribe { innerValue in channel.publish(innerValue) }
                    .autoCancel()
                    .share()
                    .store(in: &_subscriptions.wrappedValue)

            }
            .autoCancel()
            .share()
            .store(in: &_subscriptions.wrappedValue)
    }

    public let source: Source

    public func subscribe(
        _ onValue: @escaping @Sendable (Source.Value.Value) -> Void
    ) -> SimpleChannel<Source.Value.Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let _innerStreams = Synchronized<[Source.Value]>(wrappedValue: [])
    private let _subscriptions = Synchronized<Set<SharedAutoSubscription>>(wrappedValue: [])
    
    private let channel = SimpleChannel<Source.Value.Value>()
}
