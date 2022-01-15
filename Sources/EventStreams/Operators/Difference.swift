//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func difference<Result>(
        _ differentiator: @escaping (Value, Value) -> Result
    ) -> EventStream<Result> {

        EventStream<Result>(
            registerValues: { publish, complete in

                DifferenceSource(
                    source: self,
                    differentiator: differentiator,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class DifferenceSource<Value, Result>
{
    init(
        source: EventStream<Value>,
        differentiator: @escaping (Value, Value) -> Result,
        publish: @escaping (Result) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        
        var lastOpt: Value?

        self.subscription = source.subscribe(
            onValue: { value in
                
                if let last = lastOpt {
                    publish(differentiator(value, last))
                }
                
                lastOpt = value
            },
            onComplete: complete
        )
    }

    let source: EventStream<Value>
    
    let subscription: Subscription
}
