//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func accumulate<Result>(
        initialValue: Result,
        _ accumulator: @escaping (Result, Value) -> Result
    ) -> EventStream<Result> {

        EventStream<Result>(
            registerValues: { publish, complete in

                AccumulateSource(
                    source: self,
                    initialValue: initialValue,
                    accumulator: accumulator,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class AccumulateSource<Value, Result>
{
    init(
        source: EventStream<Value>,
        initialValue: Result,
        accumulator: @escaping (Result, Value) -> Result,
        publish: @escaping (Result) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        
        var last = initialValue

        self.subscription = source.subscribe(
            onValue: { event in

                last = accumulator(last, event)
                publish(last)
            },
            onComplete: complete
        )
    }

    let source: EventStream<Value>
    
    let subscription: Subscription
}
