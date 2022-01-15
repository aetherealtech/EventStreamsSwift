//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func buffer(count: Int, stride: Int) -> EventStream<[Value]> {

        EventStream<[Value]>(
            registerValues: { publish, complete in

                BufferSource(
                    source: self,
                    count: count,
                    stride: stride,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class BufferSource<Value>
{
    init(
        source: EventStream<Value>,
        count: Int,
        stride: Int,
        publish: @escaping ([Value]) -> Void,
        complete: @escaping () -> Void
    ) {

        self.source = source

        let skip = max(stride - count, 0)
        var toSkip = 0

        var values: [Value] = []

        self.subscription = source.subscribe(
            onValue: { value in

                if toSkip > 0 {
                    toSkip -= 1
                    return
                }

                values.append(value)

                if values.count < count {
                    return
                }

                publish(values)

                values.removeFirst(min(stride, values.count))
                toSkip = skip
            },
            onComplete: complete
        )
    }

    let source: EventStream<Value>

    let subscription: Subscription
}
