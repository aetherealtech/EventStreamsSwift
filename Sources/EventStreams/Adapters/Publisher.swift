 //
//  Created by Daniel Coleman on 4/1/24.
//

import CollectionExtensions
import Combine
import Observer
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream {
    var publisher: EventStreamPublisher<Self> {
        .init(stream: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct EventStreamPublisher<Stream: EventStream>: Publisher {
    public typealias Output = Stream.Value
    public typealias Failure = Never
    
    init(
        stream: Stream
    ) {
        self.stream = stream
    }
    
    public func receive<S: Combine.Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Subscription<S>(
            stream: stream,
            subscriber: subscriber
        ))
    }
    
    public let stream: Stream
    
    private final class Subscription<S: Combine.Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        init(
            stream: Stream,
            subscriber: S
        ) {
            self.stream = stream
            
            _state = .init(wrappedValue: .init(
                subscriber: subscriber
            ))
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else {
                return
            }
            
            _state.write { [_state] state in
                state.demand = demand
 
                state.subscription = stream
                    .subscribe { value in
                        _state.write { state in
                            if state.demand > .none {
                                state.demand -= 1
                                state.demand += state.subscriber.receive(value)
                            } else {
                                state.subscription = nil
                            }
                        }
                    }
                    .autoCancel()
                    .share()
            }
        }
        
        func cancel() {
            _state.write { state in
                state.subscription = nil
            }
        }
        
        private struct State {
            let subscriber: S
            var demand = Subscribers.Demand.none
            var subscription: SharedAutoSubscription?
        }
        
        private let stream: Stream
        
        @Synchronized
        private var state: State
    }
}
