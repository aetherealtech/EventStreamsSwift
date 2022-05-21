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

extension PubChannel {

    func publish<UnderlyingValue>(_ value: UnderlyingValue) where Value == Event<UnderlyingValue> {

        publish(Event(value))
    }
}

public class EventStream<Value> {

    public init<EventChannel: SubChannel>(
        channel: EventChannel
    ) where EventChannel.Value == Event<Value> {

        self.eventChannel = channel.erase()
    }

    public final func subscribe(
        onEvent: @escaping (Event<Value>) -> Void
    ) -> Subscription {

        eventChannel.subscribe(onEvent)
    }

    public final func subscribe(
        onValue: @escaping (Value) -> Void
    ) -> Subscription {

        subscribe(onEvent: { event in onValue(event.value) })
    }

    private let eventChannel: AnySubChannel<Event<Value>>
}
