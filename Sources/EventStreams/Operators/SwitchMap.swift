//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func switchMap<Result>(_ transform: @escaping (Value) -> EventStream<Result>) -> EventStream<Result> {

        self
            .map(transform)
            .switch()
    }

    public func switchMap<ResultValue>(_ transform: @escaping (Value) throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        TrySwitchMapEventStream(
            source: self,
            transform: transform
        )
    }
}

class TrySwitchMapEventStream<Input, Value> : EventStream<Result<Value, Error>>
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

        outerSubscription = source
            .subscribe { outerEvent in

                do {

                    let innerStream = try transform(outerEvent)

                    self.innerSource = innerStream

                    self.innerSubscription = innerStream
                        .subscribe  { value in

                            eventChannel.publish(.success(value))
                        }

                } catch(let error) {

                    eventChannel.publish(.failure(error))
                }
            }
    }

    private let source: EventStream<Input>
    private var innerSource: EventStream<Value>?

    private var outerSubscription: Subscription? = nil
    private var innerSubscription: Subscription? = nil
}
