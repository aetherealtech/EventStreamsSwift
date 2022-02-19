//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions
import Observer

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension EventStream {

    public func await<Success>() -> EventStream<Result<Success, Error>> where Value == Task<Event<Success>, Error> {

        EventStream<Result<Success, Error>>(
            registerEvents:
            { publish, complete in

                AwaitEventSource<Success, Error>(
                    source: self,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in


            }
        )
    }

    public func await<Success>() -> EventStream<Success> where Value == Task<Event<Success>, Never> {

        self.map { task in Task<Event<Success>, Error> { await task.value } }
                .await()
                .map { result in try! result.get() }
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

extension Result {

    func toEvent<Value>() -> Event<Result<Value, Failure>> where Success == Event<Value> {

        switch self {

        case let .success(event):
            return Event<Result<Value, Failure>>(.success(event.value), time: event.time)

        case let .failure(error):
            return Event<Result<Value, Failure>>(.failure(error))
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class AwaitEventSource<Success, Failure: Error>
{
    init(
        source: EventStream<Task<Event<Success>, Failure>>,
        publish: @escaping (Event<Result<Success, Failure>>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source

        self.sourceSubscription = source.subscribe(
            onEvent: { event in

                Task {

                    publish(await event.value.result.toEvent())
                }
            },
            onComplete: complete
        )
    }

    private let source: EventStream<Task<Event<Success>, Failure>>

    private let sourceSubscription: Subscription
}