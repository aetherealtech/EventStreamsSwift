//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import Observer

open class EventStream<Value> {

    public init<EventChannel: SubChannel>(
        channel: EventChannel
    ) where EventChannel.Value == Value {

        self.eventChannel = channel.erase()
    }

    public final func subscribe(
        _ onValue: @escaping (Value) -> Void
    ) -> Subscription {

        eventChannel.subscribe(onValue)
    }

    private let eventChannel: AnySubChannel<Value>
}
