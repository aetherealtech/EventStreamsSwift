//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func switchMap<Result>(_ transform: @escaping (Value) -> EventStream<Result>) -> EventStream<Result> {

        switchMap { value, time in

            transform(value)
        }
    }

    public func switchMap<Result>(_ transform: @escaping (Value, Date) -> EventStream<Result>) -> EventStream<Result> {

        self
                .map(transform)
                .switch()
    }

    public func switchMap<ResultValue>(_ transform: @escaping (Value) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        switchMap { value, time in

            try transform(value)
        }
    }

    public func switchMap<ResultValue>(_ transform: @escaping (Value, Date) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        TrySwitchMapEventStream(
            source: self,
            transform: { event in

                try transform(event.value, event.time)
            }
        )
    }
}

class TrySwitchMapEventStream<Input, Value> : EventStream<Result<Value, Error>>
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

        outerSubscription = source
                .subscribe(
                    onEvent: { outerEvent in

                        do {

                            let innerStream = try transform(outerEvent)

                            self.innerSource = innerStream

                            self.innerSubscription = innerStream
                                    .subscribe(
                                        onEvent: { event in

                                            eventChannel.publish(Event(.success(event.value), time: event.time))
                                        }
                                    )

                        } catch(let error) {

                            eventChannel.publish(.failure(error))
                        }
                    }
                )
    }

    private let source: EventStream<Input>
    private var innerSource: EventStream<Value>?

    private var outerSubscription: Subscription! = nil
    private var innerSubscription: Subscription! = nil
}
