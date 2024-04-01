//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

public extension EventStream {
    func map<Result>(
        _ transform: @escaping @Sendable (Value) -> Result
    ) -> MapEventStream<Self, Result> {
        .init(
            source: self,
            transform: transform
        )
    }

    func map<ResultValue>(
        _ transform: @escaping @Sendable (Value) throws -> ResultValue
    ) -> MapEventStream<Self, Result<ResultValue, any Error>> {
        map { value in .init { try transform(value) } }
    }
}

public struct MapEventStream<
    Source: EventStream,
    Result
>: EventStream {
    init(
        source: Source,
        transform: @escaping @Sendable (Source.Value) -> Result
    ) {
        self.source = source
        self.transform = transform
        
        subscription = source
            .subscribe { [channel] value in
                channel.publish(transform(value))
            }
            .autoCancel()
            .share()
    }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Result) -> Void
    ) -> SimpleChannel<Result>.Subscription {
        channel.subscribe(onValue)
    }

    public let source: Source
    public let transform: @Sendable (Source.Value) -> Result
    
    private let channel = SimpleChannel<Result>()
    private let subscription: SharedAutoSubscription
}
