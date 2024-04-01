//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import ResultExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream {
    func await<Success>() -> AwaitEventStream<Success, Self> where Value == Task<Success, Never> {
        .init(
            source: self
        )
    }
    
    func await<Success>() -> TryAwaitEventStream<Success, Self> where Value == Task<Success, Error> {
        .init(
            source: self
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AwaitEventStream<Value, Source: EventStream<Task<Value, Never>>>: EventStream {
    init(
        source: Source
    ) {
        self.source = source
        
        self.subscription = source
            .subscribe { [channel] task in
                Task { channel.publish(await task.value) }
            }
            .autoCancel()
            .share()
    }

    public let source: Source
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }

    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct TryAwaitEventStream<Success, Source: EventStream<Task<Success, any Error>>>: EventStream {
    public typealias Value = Result<Success, any Error>
    
    init(
        source: Source
    ) {
        self.source = source
        
        self.subscription = source
            .subscribe { [channel] task in
                Task {
                    channel.publish(await .init { try await task.value })
                }
            }
            .autoCancel()
            .share()
    }

    public let source: Source
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }

    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}
