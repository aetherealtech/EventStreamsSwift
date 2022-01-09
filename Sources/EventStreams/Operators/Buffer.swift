//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func buffer(count: Int, stride: Int) -> EventStream<[Payload]> {

        let stream = EventStream<[Payload]>()

        let skip = max(stride - count, 0)
        
        var items: [Payload] = []
        var toSkip = 0

        stream.subscriptions.insert(subscribe { event in

            if toSkip > 0 {
                toSkip -= 1
                return
            }
            
            items.append(event)

            if items.count < count {
                return
            }

            stream.publish(items)

            items.removeFirst(min(stride, items.count))
            toSkip = skip
        })

        return stream
    }
}
