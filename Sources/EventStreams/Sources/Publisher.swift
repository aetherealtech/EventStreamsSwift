//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Combine
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {

    func toEventStream() -> EventStream<Result<Output, Failure>> {

        EventStream(
            registerValues: { publish, complete -> AnyCancellable in

                sink(
                    receiveCompletion: { result in
                        
                        if case .failure(let error) = result {
                            publish(.failure(error))
                        }
                        
                        complete()
                    },
                    receiveValue: { value in publish(.success(value)) }
                )
            },
            unregister: { cancellable in

                
            }
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {

    func toEventStream() -> EventStream<Output> {

        let eventStream: EventStream<Result<Output, Failure>> = toEventStream()

        return eventStream
            .map { result -> Output in

                guard case .success(let value) = result else { fatalError() }

                return value
            }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {
    
    class EventStreamPublisher: Publisher {

        typealias Output = Event<Value>
        typealias Failure = Never
        
        init(
            stream: EventStream
        ) {
            
            self.stream = stream
        }
        
        func receive<S>(subscriber: S) where S : Combine.Subscriber, S.Failure == Never, S.Input == Event<Value> {
            
            stream
                .subscribe { event in
                    
                    _ = subscriber.receive(event)
                }
                .store(in: &subscriptions)
        }
        
        private let stream: EventStream
        
        private var subscriptions = Set<Observer.Subscription>()
    }
    
    func toPublisher() -> AnyPublisher<Event<Value>, Never> {
        
        EventStreamPublisher(stream: self).eraseToAnyPublisher()
    }

    func toPublisher() -> AnyPublisher<Value, Never> {

        let publisher: AnyPublisher<Event<Value>, Never> = toPublisher()

        return publisher
            .map { event in event.value }
            .eraseToAnyPublisher()
    }
}
