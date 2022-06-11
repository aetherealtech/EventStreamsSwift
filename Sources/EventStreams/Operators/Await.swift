//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func await<Success>() -> EventStream<Result<Success, Error>> where Value == Task<Success, Error> {

        TryAwaitEventStream(
            source: self
        )
    }

    public func await<Success>() -> EventStream<Success> where Value == Task<Success, Never> {

        AwaitEventStream(
            source: self
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AwaitEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<Task<Value, Never>>
    ) {

        let channel = SimpleChannel<Value>()

        self.source = source

        self.sourceSubscription = source.subscribe { task in

            Task {

                channel.publish(await task.value)
            }
        }

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Task<Value, Never>>

    private let sourceSubscription: Subscription
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TryAwaitEventStream<Success> : EventStream<Result<Success, Error>>
{
    init(
        source: EventStream<Task<Success, Error>>
    ) {

        let channel = SimpleChannel<Result<Success, Error>>()

        self.source = source

        self.sourceSubscription = source.subscribe(
            { task in

                Task {

                    let result: Result<Success, Error>

                    do {

                        result = .success(try await task.value)
                    }
                    catch(let error) {

                        result = .failure(error)
                    }

                    channel.publish(result)
                }
            }
        )

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Task<Success, Error>>

    private let sourceSubscription: Subscription
}