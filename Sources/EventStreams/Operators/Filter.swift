//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func filter(_ condition: @escaping (Value) -> Bool) -> EventStream<Value> {

        filter { value, date in
            
            condition(value)
        }
    }

    public func filter(_ condition: @escaping (Value, Date) -> Bool) -> EventStream<Value> {

        EventStream(
            registerEvents: { publish, complete in

                FilteredEventSource<Value>(
                    source: self,
                    condition: { event in condition(event.value, event.time) },
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class FilteredEventSource<Value>
{
    init(
        source: EventStream<Value>,
        condition: @escaping (Event<Value>) -> Bool,
        publish: @escaping (Event<Value>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        
        self.sourceSubscription = source.subscribe(
            onEvent: { event in
                
                if condition(event) {
                    
                    publish(event)
                }
            },
            onComplete: complete
        )
    }
    
    let source: EventStream<Value>
    let sourceSubscription: Subscription
}
