//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func difference<Result>(
        _ differentiator: @escaping (Payload, Payload) -> Result
    ) -> EventStream<Result> {

        let stream = EventStream<Result>()

        var lastOpt: Payload?

        stream.subscriptions.insert(subscribe { payload in

            if let last = lastOpt {
                stream.publish(differentiator(payload, last))
            }
            
            lastOpt = payload
        })

        return stream
    }
}
