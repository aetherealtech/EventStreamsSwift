//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func map<Result>(_ transform: @escaping (Payload) -> Result) -> EventStream<Result> {

        map { payload, date in
            
            transform(payload)
        }
    }
    
    public func map<Result>(_ transform: @escaping (Payload, Date) -> Result) -> EventStream<Result> {

        let stream = EventStream<Result>()

        stream.subscriptions.insert(subscribeWithTime { (payload, time) in stream.publish(transform(payload, time)) })

        return stream
    }
}
