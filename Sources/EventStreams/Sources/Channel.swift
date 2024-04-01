//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

public extension SubChannel {
    var stream: ChannelEventStream<Self> {
        .init(channel: self)
    }
}

public struct ChannelEventStream<Channel: SubChannel>: EventStream {
    public init(channel: Channel) {
        self.channel = channel
    }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Channel.Value) -> Void
    ) -> Channel.Subscription {
        channel.subscribe(onValue)
    }
    
    public let channel: Channel
}
