//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func map<Result>(_ transform: @escaping (Value) -> Result) -> EventStream<Result> {

        MappedEventStream(
            source: self,
            transform: transform
        )
    }

    public func map<ResultValue>(_ transform: @escaping (Value) throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        map { value in

            do {

                let result = try transform(value)
                return .success(result)

            } catch(let error) {

                return .failure(error)
            }
        }
    }
}

class MappedEventStream<SourceValue, ResultValue> : EventStream<ResultValue>
{
    init(
        source: EventStream<SourceValue>,
        transform: @escaping (SourceValue) -> ResultValue
    ) {

        let channel = SimpleChannel<ResultValue>()

        self.source = source

        self.sourceSubscription = source
                .subscribe { value in

                    channel.publish(transform(value))
                }

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<SourceValue>
    private let sourceSubscription: Subscription
}
