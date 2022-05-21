//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension SubChannel {

    public func asStream() -> EventStream<Value> {

        ChannelEventStream(channel: self)
    }
}

class ChannelEventStream<Value> : EventStream<Value> {
    
    public init<Channel: SubChannel>(
        channel: Channel
    ) where Channel.Value == Value {

        source = channel.erase()

        let channel = SimpleChannel<Event<Value>>()

        sourceSubscription = source.subscribe { value in channel.publish(value) }

        super.init(
            channel: channel
        )
    }

    let source: AnySubChannel<Value>
    let sourceSubscription: Subscription
}