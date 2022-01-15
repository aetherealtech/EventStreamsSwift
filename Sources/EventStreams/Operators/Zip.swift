  //
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func zip<Other>(
        _ other: EventStream<Other>
    ) -> EventStream<(Value, Other)> {

        EventStream<(Value, Other)>(
            registerValues:  { publish, complete in

                ZipSource(
                    source1: self,
                    source2: other,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
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

extension Array where Element: EventStreamProtocol {

    public func zip() -> EventStream<[Element.Value]> {

        EventStream<[Element.Value]>(
            registerValues: { publish, complete in

                ArrayZipSource(
                    sources: self,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class ZipSource<Value1, Value2>
{
    typealias Value = (Value1, Value2)
    
    init(
        source1: EventStream<Value1>,
        source2: EventStream<Value2>,
        publish: @escaping (Value) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source1 = source1
        self.source2 = source2
        
        self.complete = complete
        
        var value1: Value1?
        var value2: Value2?

        let send: () -> Void = {

            if let v1 = value1, let v2 = value2 {
                
                publish((v1, v2))
                
                value1 = nil
                value2 = nil
            }
        }

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
            complete()
        }
    }
    
    let source1: EventStream<Value1>
    let source2: EventStream<Value2>
    
    let complete: () -> Void
    
    var subscriptions = Set<Subscription>()
}

class ArrayZipSource<Source: EventStreamProtocol>
{
    typealias Value = Source.Value
    
    init(
        sources: [Source],
        publish: @escaping ([Value]) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.sources = sources
        
        self.complete = complete
        
        var values: [Value?] = sources.map { _ in nil }

        let send: () -> Void = {

            let readyValues = values.compactMap { value in value }
            guard readyValues.count == values.count else { return }
            
            publish(readyValues)
            
            values = sources.map { _ in nil }
        }

        sources.enumerated().forEach { index, sourceStream in

            var subscription: Subscription!
            
            subscription = sourceStream.subscribe(
                onEvent: { event in
                    
                    values[index] = event.value
                    send()
                },
                onComplete: {
                    
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
            complete()
        }
    }
    
    let sources: [Source]
    let complete: () -> Void
    
    var subscriptions = Set<Subscription>()
}
