//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func accumulate<Result>(
        initialValue: Result,
        publishInitial: Bool = false,
        _ accumulator: @escaping (Result, Payload) -> Result
    ) -> EventStream<Result> {

        let stream = EventStream<Result>()

        var last = initialValue
        if publishInitial {
            stream.publish(last)
        }

        stream.subscriptions.insert(subscribe { event in

            last = accumulator(last, event)
            stream.publish(last)
        })

        return stream
    }
}
