//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func await<Success>() -> EventStream<Result<Success, Error>> where Value == Task<Event<Success>, Error> {

        TryAwaitEventStream(
            source: self
        )
    }

    public func await<Success>() -> EventStream<Success> where Value == Task<Event<Success>, Never> {

        AwaitEventStream(
            source: self
        )
    }

    public func await<Success>() -> EventStream<Result<Success, Error>> where Value == Task<Success, Error> {

        self.map { task -> Task<Event<Success>, Error> in task.map { value in Event<Success>(value) }}
                .await()
    }

    public func await<Success>() -> EventStream<Success> where Value == Task<Success, Never> {

        self.map { task -> Task<Event<Success>, Never> in task.map { value in Event<Success>(value) }}
                .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class AwaitEventStream<Value> : EventStream<Value>
{
    init(
        source: EventStream<Task<Event<Value>, Never>>
    ) {

        let channel = SimpleChannel<Event<Value>>()

        self.source = source

        self.sourceSubscription = source.eventChannel.subscribe { event in

            Task {

                channel.publish(await event.value.value)
            }
        }

        super.init(
            eventChannel: channel,
            completeChannel: source.completeChannel
        )
    }

    private let source: EventStream<Task<Event<Value>, Never>>

    private let sourceSubscription: Subscription
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class TryAwaitEventStream<Success> : EventStream<Result<Success, Error>>
{
    init(
        source: EventStream<Task<Event<Success>, Error>>
    ) {

        let channel = SimpleChannel<Event<Result<Success, Error>>>()

        self.source = source

        self.sourceSubscription = source.eventChannel.subscribe { event in

            Task {

                let result: Event<Result<Success, Error>>

                do {

                    let resultEvent = try await event.value.value
                    result = Event(.success(resultEvent.value), time: resultEvent.time)
                }
                catch(let error) {

                    result = Event(.failure(error))
                }

                channel.publish(result)
            }
        }

        super.init(
            eventChannel: channel,
            completeChannel: source.completeChannel
        )
    }

    private let source: EventStream<Task<Event<Success>, Error>>

    private let sourceSubscription: Subscription
}