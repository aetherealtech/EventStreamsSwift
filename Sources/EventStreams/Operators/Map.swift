//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func map<Result>(_ transform: @escaping (Value) -> Result) -> EventStream<Result> {

        map { value, _ in

            Event<Result>(transform(value))
        }
    }

    public func map<Result>(_ transform: @escaping (Value, Date) -> Result) -> EventStream<Result> {

        map { value, time in

            Event<Result>(transform(value, time))
        }
    }

    public func map<Result>(_ transform: @escaping (Value) -> Event<Result>) -> EventStream<Result> {

        map { value, _ in

            transform(value)
        }
    }

    public func map<Result>(_ transform: @escaping (Value, Date) -> Event<Result>) -> EventStream<Result> {

        MappedEventStream(
            source: self,
            transform: { event in transform(event.value, event.time) }
        )
    }

    public func map<ResultValue>(_ transform: @escaping (Value) throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        map { value, _ in

            Event<ResultValue>(try transform(value))
        }
    }

    public func map<ResultValue>(_ transform: @escaping (Value, Date) throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        map { value, time in

            Event<ResultValue>(try transform(value, time))
        }
    }

    public func map<ResultValue>(_ transform: @escaping (Value) throws -> Event<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        map { value, _ in

            try transform(value)
        }
    }

    public func map<ResultValue>(_ transform: @escaping (Value, Date) throws -> Event<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        map { (value, time) in

            do {

                let result = try transform(value, time)
                return Event(.success(result.value), time: result.time)

            } catch(let error) {

                return Event(.failure(error))
            }
        }
    }
}

class MappedEventStream<SourceValue, ResultValue> : EventStream<ResultValue>
{
    init(
        source: EventStream<SourceValue>,
        transform: @escaping (Event<SourceValue>) -> Event<ResultValue>
    ) {

        let channel = SimpleChannel<Event<ResultValue>>()

        self.source = source

        self.sourceSubscription = source
                .subscribe { event in

                    channel.publish(transform(event))
                }

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<SourceValue>
    private let sourceSubscription: Subscription
}
