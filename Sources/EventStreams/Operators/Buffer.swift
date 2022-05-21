//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func buffer(count: Int, stride: Int) -> EventStream<[Value]> {

        BufferEventStream(
            source: self,
            count: count,
            stride: stride
        )
    }
}

class BufferEventStream<Value> : EventStream<[Value]>
{
    init(
        source: EventStream<Value>,
        count: Int,
        stride: Int
    ) {

        self.source = source

        let skip = max(stride - count, 0)
        var toSkip = 0

        var values: [Value] = []

        let channel = SimpleChannel<Event<[Value]>>()

        self.subscription = source.eventChannel.subscribe { event in

            let value = event.value

            if toSkip > 0 {
                toSkip -= 1
                return
            }

            values.append(value)

            if values.count < count {
                return
            }

            channel.publish(Event(values))

            values.removeFirst(min(stride, values.count))
            toSkip = skip
        }

        super.init(
            eventChannel: channel,
            completeChannel: source.completeChannel
        )
    }

    private let source: EventStream<Value>

    private let subscription: Subscription
}
