//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

public extension EventStream {
    func switchMap<Result: EventStream>(
        _ transform: @escaping @Sendable (Value) -> Result
    ) -> SwitchEventStream<MapEventStream<Self, Result>> {
        self
            .map(transform)
            .switch()
    }

    func switchMap<Result: EventStream>(
        _ transform: @escaping @Sendable (Value) throws -> Result
    ) -> TrySwitchMapEventStream<Self, Result> {
        .init(
            source: self,
            transform: transform
        )
    }
}

public struct TrySwitchMapEventStream<
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

        self.outerSubscription = source
            .subscribe { [channel, _innerStream, _innerSubscription] outerValue in
                do {
                    let innerStream = try transform(outerValue)
                    _innerStream.wrappedValue = innerStream
                    
                    _innerSubscription.wrappedValue = innerStream
                        .subscribe { innerValue in channel.publish(.success(innerValue)) }
                        .autoCancel()
                        .share()
                } catch {
                    channel.publish(.failure(error))
                }
            }
            .autoCancel()
            .share()
    }

    public let source: Source
    public let transform: @Sendable (Source.Value) throws -> ResultValue
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let _innerStream = Synchronized<ResultValue?>(wrappedValue: nil)
    
    private let outerSubscription: SharedAutoSubscription
    private let _innerSubscription = Synchronized<SharedAutoSubscription?>(wrappedValue: nil)
    
    private let channel = SimpleChannel<Value>()
}
