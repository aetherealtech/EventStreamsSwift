//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

public extension EventStream {
    func flatMap<Result: EventStream>(_ transform: @escaping @Sendable (Value) -> Result) -> FlattenEventStream<MapEventStream<Self, Result>> {
        self
            .map(transform)
            .flatten()
    }

    func flatMap<ResultValue>(_ transform: @escaping @Sendable (Value) throws -> ResultValue) -> TryFlatMapEventStream<Self, ResultValue> {
        .init(
            source: self,
            transform: transform
        )
    }
}

public struct TryFlatMapEventStream<
    Source: EventStream,
    ResultValue: EventStream
>: EventStream {
    public typealias Value = Result<ResultValue.Value, any Error>
    
    init(
        source: Source,
        transform: @escaping @Sendable (Source.Value) throws -> ResultValue
    ) {
        self.source = source
        self.transform = transform

        source
            .subscribe { [channel, _innerStreams, _subscriptions] outerValue in
                do {
                    let innerStream = try transform(outerValue)
                    _innerStreams.wrappedValue.append(innerStream)
                    
                    innerStream
                        .subscribe { innerValue in channel.publish(.success(innerValue)) }
                        .autoCancel()
                        .share()
                        .store(in: &_subscriptions.wrappedValue)
                } catch {
                    channel.publish(.failure(error))
                }
            }
            .autoCancel()
            .share()
            .store(in: &_subscriptions.wrappedValue)
    }

    public let source: Source
    public let transform: @Sendable (Source.Value) throws -> ResultValue
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let _innerStreams = Synchronized<[ResultValue]>(wrappedValue: [])
    private let _subscriptions = Synchronized<Set<SharedAutoSubscription>>(wrappedValue: [])
    
    private let channel = SimpleChannel<Value>()
}
