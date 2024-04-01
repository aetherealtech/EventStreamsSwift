//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

public extension EventStream {
    func collect(
        until: @escaping @Sendable (Value) -> Bool,
        strideUntil: @escaping @Sendable (Value) -> Bool
    ) -> CollectUntilEventStream<Self> {
        .init(
            source: self,
            terminateCollect: until,
            terminateStride: strideUntil
        )
    }
}

public extension EventStream where Value: Equatable & Sendable {
    func collectUntil(
        terminateCollectOn: Value,
        terminateStrideOn: Value
    ) -> CollectUntilEventStream<Self> {
        collect(
            until: { value in value == terminateCollectOn },
            strideUntil: { value in value == terminateStrideOn }
        )
    }
}

public struct CollectUntilEventStream<Source: EventStream>: EventStream {
    public typealias Value = [Source.Value]
    init(
        source: Source,
        terminateCollect: @escaping @Sendable (Source.Value) -> Bool,
        terminateStride: @escaping @Sendable (Source.Value) -> Bool
    ) {
        self.source = source
        self.terminateCollect = terminateCollect
        self.terminateStride = terminateStride

        self.subscription = source.subscribe(
            { [channel, _state] value in
                let values = _state.write { state -> Value? in
                    if state.striding {
                        state.striding = !terminateStride(value)
                        return nil
                    }
                    
                    state.values.append(value)
                    
                    if !terminateCollect(value) {
                        return nil
                    }
                    
                    state.striding = true
                    
                    while state.striding, !state.values.isEmpty {
                        state.striding = !terminateStride(state.values.removeFirst())
                    }
                    
                    return state.values
                }
                
                if let values {
                    channel.publish(values)
                }
            }
        )
    }

    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    public let source: Source
    public let terminateCollect: @Sendable (Source.Value) -> Bool
    public let terminateStride: @Sendable (Source.Value) -> Bool

    private let channel = SimpleChannel<Value>()
    private let subscription: Subscription
    
    private struct State {
        var values: Value = []
        var striding = false
    }
    
    private let _state = Synchronized<State>(wrappedValue: .init())
}
