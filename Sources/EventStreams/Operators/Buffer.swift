//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions
import Observer

extension EventStream {

    public func buffer(
        count: Int,
        prefill: Value? = nil
    ) -> EventStream<[Value]> {

        buffer(
            count: count,
            stride: count,
            prefill: prefill
        )
    }

    public func buffer(
        count: Int,
        stride: Int,
        prefill: Value? = nil
    ) -> EventStream<[Value]> {

        BufferEventStream(
            source: self,
            count: count,
            stride: stride,
            prefill: prefill
        )
    }
}

class BufferEventStream<Value> : EventStream<[Value]>
{
    init(
        source: EventStream<Value>,
        count: Int,
        stride: Int,
        prefill: Value?
    ) {

        self.source = source

        let skip = max(stride - count, 0)
        var toSkip = 0

        var values = [Value?](repeating: prefill, count: count - 1).compact()

        let channel = SimpleChannel<[Value]>()

        self.subscription = source.subscribe(
            { value in

                if toSkip > 0 {
                    toSkip -= 1
                    return
                }

                values.append(value)

                if values.count < count {
                    return
                }

                channel.publish(values)

                values.removeFirst(min(stride, values.count))
                toSkip = skip
            }
        )

        super.init(
            channel: channel
        )
    }

    private let source: EventStream<Value>

    private let subscription: Subscription
}
