//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Combine
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {

    func toEventStream() -> EventStream<Result<Output, Failure>> {

        TryPublisherEventStream(source: self)
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Failure == Never {

    func toEventStream() -> EventStream<Output> {

        PublisherEventStream(source: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PublisherEventStream<Source: Publisher> : EventStream<Source.Output> where Source.Failure == Never {

    typealias Value = Source.Output

    init(
        source: Source
    ) {

        self.source = source

        let eventChannel = SimpleChannel<Event<Value>>()

        subscription = source.sink(
            receiveValue: { value in eventChannel.publish(value) }
        )

        super.init(
            channel: eventChannel
        )
    }

    private let source: Source

    private let subscription: AnyCancellable
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TryPublisherEventStream<Source: Publisher> : EventStream<Result<Source.Output, Source.Failure>> {

    typealias Value = Result<Source.Output, Source.Failure>

    init(
        source: Source
    ) {

        self.source = source

        let eventChannel = SimpleChannel<Event<Value>>()

        subscription = source.sink(
            receiveCompletion: { result in

                if case .failure(let error) = result {
                    eventChannel.publish(.failure(error))
                }
            },
            receiveValue: { value in eventChannel.publish(.success(value)) }
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
