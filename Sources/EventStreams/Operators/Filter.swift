//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func filter(_ condition: @escaping (Payload) -> Bool) -> EventStream<Payload> {

        filter { payload, date in
            
            condition(payload)
        }
    }

    public func filter(_ condition: @escaping (Payload, Date) -> Bool) -> EventStream<Payload> {

        let stream = EventStream<Payload>()

        stream.subscriptions.insert(subscribeWithTime { event in

            if condition(event.payload, event.time) {
                stream.publish(event)
            }
        })

        return stream
    }
}
