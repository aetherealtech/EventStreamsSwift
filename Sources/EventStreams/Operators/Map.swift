//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func map<Result>(_ transform: @escaping (Value) -> Result) -> EventStream<Result> {

        map { value, _ in
            
            Event<Result>(transform(value))
        }
    }
    
    public func map<Result>(_ transform: @escaping (Value, Date) -> Result) -> EventStream<Result> {

        map { value, time in
            
            Event<Result>(transform(value, time))
        }
    }
    
    public func map<Result>(_ transform: @escaping (Value) -> Event<Result>) -> EventStream<Result> {

        map { value, _ in
            
            transform(value)
        }
    }
    
    public func map<Result>(_ transform: @escaping (Value, Date) -> Event<Result>) -> EventStream<Result> {

        EventStream<Result>(
            registerEvents:
            { publish, complete in

                MappedEventSource<Value, Result>(
                    source: self,
                    transform: { event in transform(event.value, event.time) },
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class MappedEventSource<SourceValue, ResultValue>
{
    init(
        source: EventStream<SourceValue>,
        transform: @escaping (Event<SourceValue>) -> Event<ResultValue>,
        publish: @escaping (Event<ResultValue>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        
        self.sourceSubscription = source.subscribe(
            onEvent: { event in publish(transform(event)) },
            onComplete: complete
        )
    }
    
    let source: EventStream<SourceValue>
    let sourceSubscription: Subscription
}