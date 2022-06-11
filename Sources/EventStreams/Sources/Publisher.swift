//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Combine
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {

    func toEventStream() -> EventStream<Result<Output, Failure>> {

        PublisherEventStream(source: self)
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {

    func toEventStream() -> EventStream<Output> {

        toEventStream()
            .ignoreErrors()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PublisherEventStream<Source: Publisher> : EventStream<Result<Source.Output, Source.Failure>> {

    typealias Value = Result<Source.Output, Source.Failure>

    init(
        source: Source
    ) {

        self.source = source

        let eventChannel = SimpleChannel<Value>()

        subscription = source.sink(
            receiveCompletion: { result in

                if case .failure(let error) = result {
                    eventChannel.publish(.failure(error))
                }
            },
            receiveValue: { value in

                eventChannel.publish(.success(value))
            }
        )

        super.init(
            channel: eventChannel
        )
    }

    private let source: Source

    private let subscription: AnyCancellable
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {
    
    class EventStreamPublisher: Publisher {

        typealias Output = Value
        typealias Failure = Never
        
        init(
            stream: EventStream
        ) {
            
            self.stream = stream
        }
        
        func receive<S>(subscriber: S) where S : Combine.Subscriber, S.Failure == Never, S.Input == Value {
            
            stream
                .subscribe { value in

                    _ = subscriber.receive(value)
                }
                .store(in: &subscriptions)
        }
        
        private let stream: EventStream
        
        private var subscriptions = Set<Observer.Subscription>()
    }
    
    func toPublisher() -> AnyPublisher<Value, Never> {
        
        EventStreamPublisher(stream: self).eraseToAnyPublisher()
    }
}
