//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

public extension EventStream where Value: EventStream {
    func `switch`() -> SwitchEventStream<Self> {
        .init(
            source: self
        )
    }
}

public struct SwitchEventStream<Source: EventStream>: EventStream where Source.Value: EventStream {
    init(
        source: Source
    ) {
        self.source = source

        self.outerSubscription = source
            .subscribe { [channel, _innerStream, _innerSubscription] innerStream in
                _innerStream.wrappedValue = innerStream

                _innerSubscription.wrappedValue = innerStream
                    .subscribe { innerValue in channel.publish(innerValue) }
                    .autoCancel()
                    .share()

            }
            .autoCancel()
            .share()
    }

    public let source: Source

    public func subscribe(
        _ onValue: @escaping @Sendable (Source.Value.Value) -> Void
    ) -> SimpleChannel<Source.Value.Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let _innerStream = Synchronized<Source.Value?>(wrappedValue: nil)
    
    private let outerSubscription: SharedAutoSubscription
    private let _innerSubscription = Synchronized<SharedAutoSubscription?>(wrappedValue: nil)
    
    private let channel = SimpleChannel<Source.Value.Value>()
}
