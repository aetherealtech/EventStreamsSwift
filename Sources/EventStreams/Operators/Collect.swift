//
//  Created by Daniel Coleman on 1/9/22.
//

import CollectionExtensions
import Foundation
import Observer
import Synchronization

public extension EventStream {
    func collect(
        count: Int,
        prefill: Value? = nil
    ) -> CollectEventStream<Self> {
        collect(
            count: count,
            stride: count,
            prefill: prefill
        )
    }

    func collect(
        count: Int,
        stride: Int,
        prefill: Value? = nil
    ) -> CollectEventStream<Self> {
        .init(
            source: self,
            count: count,
            stride: stride,
            prefill: prefill
        )
    }
}

public struct CollectEventStream<Source: EventStream>: EventStream {
    public typealias Value = [Source.Value]
    init(
        source: Source,
        count: Int,
        stride: Int,
        prefill: Source.Value?
    ) {
        self.source = source
        self.count = count
        self.stride = stride
        self._prefill = .init(wrappedValue: prefill)

        _state = .init(wrappedValue: .init(values: [Source.Value?](repeating: prefill, count: count - 1).compact()))
        
        self.subscription = source.subscribe(
            { [channel, _state] value in
                let values = _state.write { state -> Value? in
                    if state.stride > 0 {
                        state.stride -= 1
                        return nil
                    }
                    
                    state.values.append(value)
                    
                    if state.values.count == count {
                        let readyValues = state.values
                        let overlap = min(stride, count)
                        state.values.removeFirst(overlap)
                        state.stride = stride - overlap
                        return readyValues
                    }
                    
                    return nil
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
    public let count: Int
    public let stride: Int
    public var prefill: Source.Value? { _prefill.wrappedValue }

    private let channel = SimpleChannel<Value>()
    private let subscription: Subscription
    
    private struct State {
        var values: Value
        var stride = 0
    }
    
    private let _prefill: Synchronized<Source.Value?>
    private let _state: Synchronized<State>
}
