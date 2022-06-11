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

        self
            .map(transform)
            .flatten()
    }

    public func flatMap<ResultValue>(_ transform: @escaping (Value) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        TryFlatMapEventStream(
            source: self,
            transform: transform
        )
    }
}

class TryFlatMapEventStream<Input, Value> : EventStream<Result<Value, Error>>
{
    init(
        source: EventStream<Input>,
        transform: @escaping (Input) throws -> EventStream<Value>
    ) {

        let eventChannel = SimpleChannel<Result<Value, Error>>()

        self.source = source

        super.init(
            channel: eventChannel
        )

        source
            .subscribe { outerValue in

                let innerStream: EventStream<Value>

                do {

                    innerStream = try transform(outerValue)

                    self.innerStreams.append(innerStream)

                    innerStream
                        .subscribe { innerValue in

                            eventChannel.publish(.success(innerValue))
                        }
                        .store(in: &self.subscriptions)

                } catch(let error) {

                    eventChannel.publish(.failure(error))
                }
            }
            .store(in: &subscriptions)
    }

    private let source: EventStream<Input>

    private var innerStreams = [EventStream<Value>]()
    private var subscriptions = Set<Subscription>()
}
