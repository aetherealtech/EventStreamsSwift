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

        MappedEventStream(
            source: self,
            transform: { event in transform(event.value, event.time) }
        )
    }
}

class MappedEventStream<SourceValue, ResultValue> : EventStream<ResultValue>
{
    init(
        source: EventStream<SourceValue>,
        transform: @escaping (Event<SourceValue>) -> Event<ResultValue>
    ) {

        let channel = SimpleChannel<Event<ResultValue>>()

        self.source = source

        self.sourceSubscription = source.eventChannel
                .subscribe { event in

                    channel.publish(transform(event))
                }

        super.init(
            eventChannel: channel,
            completeChannel: source.completeChannel
        )
    }

    private let source: EventStream<SourceValue>
    private let sourceSubscription: Subscription
}
