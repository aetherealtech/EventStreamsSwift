//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

public extension EventStream {
     func filter(
        _ condition: @Sendable @escaping (Value) -> Bool
     ) -> FilteredEventStream<Self> {
         .init(
            source: self,
            condition: condition
        )
    }
}

public struct FilteredEventStream<Source: EventStream>: EventStream {
    init(
        source: Source,
        condition: @escaping @Sendable (Source.Value) -> Bool
    ) {
        self.source = source
        self.condition = condition

        self.subscription = source
                .subscribe { [channel] value in
                    if condition(value) {
                        channel.publish(value)
                    }
                }
                .autoCancel()
                .share()
    }

    public let source: Source
    public let condition: @Sendable (Source.Value) -> Bool
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Source.Value) -> Void
    ) -> SimpleChannel<Source.Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Source.Value>()
    private let subscription: SharedAutoSubscription
}
