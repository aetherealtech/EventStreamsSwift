 //
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream where Payload : EventStreamProtocol {

    public func `switch`() -> EventStream<Payload.Payload> {

        let stream = EventStream<Payload.Payload>()

        var innerSubscription: Subscription?

        stream.subscriptions.insert(subscribe { innerStream in

            if let subscription = innerSubscription {
                stream.subscriptions.remove(subscription)
            }

            let newSubscription = innerStream.subscribe(stream.publish)
            stream.subscriptions.insert(newSubscription)
            innerSubscription = newSubscription
        })

        return stream
    }
}
