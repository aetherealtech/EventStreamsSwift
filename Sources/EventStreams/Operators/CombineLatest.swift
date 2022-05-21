//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func combineLatest<Other>(
        _ other: EventStream<Other>
    ) -> EventStream<(Value, Other)> {

        CombineLatestEventStream(
            source1: self,
            source2: other
        )
    }

    public func combineLatest<Other1, Other2>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>
    ) -> EventStream<(Value, Other1, Other2)> {

        self
            .combineLatest(other1)
            .combineLatest(other2)
            .map { first, last in (first.0, first.1, last) }
    }

    public func combineLatest<Other1, Other2, Other3>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>
    ) -> EventStream<(Value, Other1, Other2, Other3)> {

        self
            .combineLatest(other1, other2)
            .combineLatest(other3)
            .map { first, last in (first.0, first.1, first.2, last) }
    }

    public func combineLatest<Other1, Other2, Other3, Other4>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>,
        _ other4: EventStream<Other4>
    ) -> EventStream<(Value, Other1, Other2, Other3, Other4)> {

        self
            .combineLatest(other1, other2, other3)
            .combineLatest(other4)
            .map { first, last in (first.0, first.1, first.2, first.3, last) }
    }
}

extension Array {

    public func combineLatest<Value>() -> EventStream<[Value]> where Element == EventStream<Value> {

        ArrayCombineLatestEventStream(
            sources: self
        )
    }
}

class CombineLatestEventStream<Value1, Value2> : EventStream<(Value1, Value2)>
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
                channel.publish(Event((v1, v2)))
            }
        }

        super.init(
            eventChannel: channel,
            completeChannel: completeChannelInternal
        )

        var subscription1: Subscription!
        
        subscription1 = source1.subscribe(
            onValue: { v1 in
                
                value1 = v1
                send()
            },
            onComplete: {
                
                self.subscriptions.remove(subscription1)
                self.checkComplete()
            }
        )
            
        subscription1
            .store(in: &subscriptions)
        
        var subscription2: Subscription!
        
        subscription2 = source2.subscribe(
            onValue: { v2 in
                
                value2 = v2
                send()
            },
            onComplete: {
                
                self.subscriptions.remove(subscription2)
                self.checkComplete()
            }
        )
        
        subscription2
            .store(in: &subscriptions)
    }
    
    private func checkComplete() {
        
        if subscriptions.isEmpty {
            completeChannelInternal.publish()
        }
    }

    private let source1: EventStream<Value1>
    private let source2: EventStream<Value2>

    private let completeChannelInternal = SimpleChannel<Void>()

    private var subscriptions = Set<Subscription>()
}

class ArrayCombineLatestEventStream<Value> : EventStream<[Value]>
{
    init(
        sources: [EventStream<Value>]
    ) {
        
        self.sources = sources

        self.values = sources.map { _ in nil }

        let channel = SimpleChannel<Event<[Value]>>()
        let completeChannelInternal = SimpleChannel<Void>()

        self.completeChannelInternal = completeChannelInternal

        super.init(
            eventChannel: channel,
            completeChannel: completeChannelInternal
        )

        let send: () -> Void = {

            let readyValues = self.values.compact()
            guard readyValues.count == self.values.count else { return }

            channel.publish(Event(readyValues))
        }

        sources.enumerated().forEach { index, sourceStream in

            var subscription: Subscription!
            
            subscription = sourceStream.subscribe(
                onEvent: { event in
                    
                    self.values[index] = event.value
                    send()
                },
                onComplete: {
                    
                    // If this stream never published a value, the combine latest stream will never publish one either
                    guard self.values[index] != nil else {
                        
                        self.subscriptions.removeAll()

                        completeChannelInternal.publish()
                        return
                    }
                    
                    self.subscriptions.remove(subscription)
                    self.checkComplete()
                }
            )
            
            subscription
                .store(in: &subscriptions)
        }
    }
    
    private func checkComplete() {
        
        if subscriptions.isEmpty {
            completeChannelInternal.publish()
        }
    }

    private let sources: [EventStream<Value>]
    private let completeChannelInternal: SimpleChannel<Void>

    private var values: [Value?]

    private var subscriptions = Set<Subscription>()
}
