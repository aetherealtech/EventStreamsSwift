//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import Observer

public struct Event<Value> {
    
    public init(
        _ value: Value,
        time: Date = Date()
    ) {
     
        self.value = value
        self.time = time
    }
    
    public let value: Value
    public let time: Date
}

extension Event: Equatable where Value: Equatable {

}

extension Event: Hashable where Value: Hashable {

}

public class EventStream<Value> {

    public init<EventChannel: SubChannel, CompleteChannel: SubChannel>(
        eventChannel: EventChannel,
        completeChannel: CompleteChannel
    ) where EventChannel.Value == Event<Value>, CompleteChannel.Value == Void {

        self.eventChannel = eventChannel.erase()
        self.completeChannel = completeChannel.erase()
    }

    public final func subscribe(
        onEvent: @escaping (Event<Value>) -> Void,
        onComplete: @escaping () -> Void
    ) -> Subscription {

        let eventSubscription = eventChannel.subscribe(onEvent)
        let onCompleteSubscription = completeChannel.subscribe(onComplete)

        return AggregateSubscription([
            eventSubscription,
            onCompleteSubscription
        ])
    }
    
    public final func subscribe(
        onEvent: @escaping (Event<Value>) -> Void
    ) -> Subscription {

        eventChannel.subscribe(onEvent)
    }
    
    public final func subscribe(
        onValue: @escaping (Value) -> Void,
        onComplete: @escaping () -> Void
    ) -> Subscription {

        subscribe(
            onEvent: { event in onValue(event.value) },
            onComplete: onComplete
        )
    }
    
    public final func subscribe(
        onValue: @escaping (Value) -> Void
    ) -> Subscription {

        subscribe(onEvent: { event in onValue(event.value) })
    }

    public let eventChannel: AnySubChannel<Event<Value>>
    public let completeChannel: AnySubChannel<Void>
}
