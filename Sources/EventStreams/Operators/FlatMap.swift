//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func flatMap<Result>(_ transform: @escaping (Value) -> EventStream<Result>) -> EventStream<Result> {

        flatMap { value, date in
            
            transform(value)
        }
    }
    
    public func flatMap<Result>(_ transform: @escaping (Value, Date) -> EventStream<Result>) -> EventStream<Result> {

        self
            .map(transform)
            .flatten()
    }

    public func flatMap<ResultValue>(_ transform: @escaping (Value) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        flatMap { value, date in

            try transform(value)
        }
    }

    public func flatMap<ResultValue>(_ transform: @escaping (Value, Date) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        TryFlatMapEventStream(
            source: self,
            transform: { event in

                try transform(event.value, event.time)
            }
        )
    }
}

class TryFlatMapEventStream<Input, Value> : EventStream<Result<Value, Error>>
{
    init(
        source: EventStream<Input>,
        transform: @escaping (Event<Input>) throws -> EventStream<Value>
    ) {

        let eventChannel = SimpleChannel<Event<Result<Value, Error>>>()

        self.source = source

        super.init(
            channel: eventChannel
        )

        source
                .subscribe(
                    onEvent: { outerEvent in

                        do {

                            let innerStream = try transform(outerEvent)

                            self.innerStreams.append(innerStream)

                            innerStream
                                    .subscribe(
                                        onEvent: { event in

                                            eventChannel.publish(Event(.success(event.value), time: event.time))
                                        }
                                    )
                                    .store(in: &self.subscriptions)

                        } catch(let error) {

                            eventChannel.publish(.failure(error))
                        }
                    }
                )
                .store(in: &subscriptions)
    }

    private let source: EventStream<Input>

    private var innerStreams = [EventStream<Value>]()
    private var subscriptions = Set<Subscription>()
}
