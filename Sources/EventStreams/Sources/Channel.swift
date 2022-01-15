//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension TypedSubChannel {

    public func asStream() -> EventStream<Value> {

        EventStream(channel: self)
    }
}

extension EventStream {
    
    public convenience init<Channel: TypedSubChannel>(
        channel: Channel
    ) where Channel.Value == Value {

        self.init(
            registerValues: { publish, complete -> Subscription in

                channel.subscribe(publish)
            },
            unregister: { subscription in

            }
        )
    }
}