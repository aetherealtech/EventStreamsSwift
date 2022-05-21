  //
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func zip<Other>(
        _ other: EventStream<Other>
    ) -> EventStream<(Value, Other)> {

        ZipEventStream(
            source1: self,
            source2: other
        )
    }

    public func zip<Other1, Other2>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>
    ) -> EventStream<(Value, Other1, Other2)> {

        self
            .zip(other1)
            .zip(other2)
            .map { first, last in (first.0, first.1, last) }
    }

    public func zip<Other1, Other2, Other3>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>
    ) -> EventStream<(Value, Other1, Other2, Other3)> {

        self
            .zip(other1, other2)
            .zip(other3)
            .map { first, last in (first.0, first.1, first.2, last) }
    }

    public func zip<Other1, Other2, Other3, Other4>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>,
        _ other4: EventStream<Other4>
    ) -> EventStream<(Value, Other1, Other2, Other3, Other4)> {

        self
            .zip(other1, other2, other3)
            .zip(other4)
            .map { first, last in (first.0, first.1, first.2, first.3, last) }
    }
}

extension Array {

    public func zip<Value>() -> EventStream<[Value]> where Element == EventStream<Value> {

        ArrayZipEventStream(
            sources: self
        )
    }
}

class ZipEventStream<Value1, Value2> : EventStream<(Value1, Value2)>
{
    typealias Value = (Value1, Value2)
    
    init(
        source1: EventStream<Value1>,
        source2: EventStream<Value2>
    ) {
        
        self.source1 = source1
        self.source2 = source2

        var value1: Value1?
        var value2: Value2?

        let channel = SimpleChannel<Event<Value>>()

        let send: () -> Void = {

            if let v1 = value1, let v2 = value2 {

                channel.publish((v1, v2))
                
                value1 = nil
                value2 = nil
            }
        }

        super.init(
            channel: channel
        )

        var subscription1: Subscription!
        
        subscription1 = source1.subscribe(
            onValue: { v1 in
                
                value1 = v1
                send()
            }
        )
            
        subscription1
            .store(in: &subscriptions)
        
        var subscription2: Subscription!
        
        subscription2 = source2.subscribe(
            onValue: { v2 in
                
                value2 = v2
                send()
            }
        )
        
        subscription2
            .store(in: &subscriptions)
    }

    private let source1: EventStream<Value1>
    private let source2: EventStream<Value2>

    private var subscriptions = Set<Subscription>()
}

class ArrayZipEventStream<Value> : EventStream<[Value]>
{
    init(
        sources: [EventStream<Value>]
    ) {
        
        self.sources = sources

        let channel = SimpleChannel<Event<[Value]>>()

        var values: [Value?] = sources.map { _ in nil }

        super.init(
            channel: channel
        )

        let send: () -> Void = {

            let readyValues = values.compactMap { value in value }
            guard readyValues.count == values.count else { return }

            channel.publish(readyValues)
            
            values = sources.map { _ in nil }
        }

        sources.enumerated().forEach { index, sourceStream in

            var subscription: Subscription!
            
            subscription = sourceStream.subscribe(
                onEvent: { event in
                    
                    values[index] = event.value
                    send()
                }
            )
            
            subscription
                .store(in: &subscriptions)
        }
    }

    private let sources: [EventStream<Value>]

    private var subscriptions = Set<Subscription>()
}
