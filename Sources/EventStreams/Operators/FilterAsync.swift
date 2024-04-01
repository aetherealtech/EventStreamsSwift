//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream where Value: Sendable {
    func filter(
        _ condition: @escaping @Sendable (Value) async -> Bool
    ) -> FilteredAsyncEventStream<Self> {
        .init(
            source: self,
            condition: condition
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct FilteredAsyncEventStream<Source: EventStream>: EventStream where Source.Value: Sendable {
    init(
        source: Source,
        condition: @escaping @Sendable (Source.Value) async -> Bool
    ) {
        self.source = source
        self.condition = condition

        self.subscription = source
                .subscribe { [channel] value in
                    Task {
                        if await condition(value) {
                            channel.publish(value)
                        }
                    }
                }
                .autoCancel()
                .share()
    }

    public let source: Source
    public let condition: @Sendable (Source.Value) async -> Bool
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Source.Value) -> Void
    ) -> SimpleChannel<Source.Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Source.Value>()
    private let subscription: SharedAutoSubscription
}
