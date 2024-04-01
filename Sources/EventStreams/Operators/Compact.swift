//
//  Created by Daniel Coleman on 1/9/22.
//

import Observer

public extension EventStream {
    func compact<Wrapped>() -> CompactEventStream<Wrapped, Self> where Value == Wrapped? {
        .init(source: self)
    }
}

public struct CompactEventStream<
    Wrapped,
    Source: EventStream
>: EventStream where Source.Value == Wrapped? {
    init(
        source: Source
    ) {
        self.source = source

        self.subscription = source
                .subscribe { [channel] value in
                    if let value {
                        channel.publish(value)
                    }
                }
                .autoCancel()
                .share()
    }

    public let source: Source
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Wrapped) -> Void
    ) -> SimpleChannel<Wrapped>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Wrapped>()
    private let subscription: SharedAutoSubscription
}
