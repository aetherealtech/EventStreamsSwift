//
//  Created by Daniel Coleman on 1/9/22.
//

import CollectionExtensions
import Observer
import Synchronization

//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public func zip<each E: EventStream>(
//    _ eventStreams: repeat each E
//) -> ZipEventStream<repeat each E> {
//    .init(
//        eventStreams
//    )
//}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func zip<
    E1: EventStream,
    E2: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2
) -> ZipEventStream2<E1, E2> {
    .init(
        eventStream1,
        eventStream2
    )
}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func zip<
    E1: EventStream,
    E2: EventStream,
    E3: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2,
    _ eventStream3: E3
) -> ZipEventStream3<E1, E2, E3> {
    .init(
        eventStream1,
        eventStream2,
        eventStream3
    )
}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func zip<
    E1: EventStream,
    E2: EventStream,
    E3: EventStream,
    E4: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2,
    _ eventStream3: E3,
    _ eventStream4: E4
) -> ZipEventStream4<E1, E2, E3, E4> {
    .init(
        eventStream1,
        eventStream2,
        eventStream3,
        eventStream4
    )
}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func zip<
    E1: EventStream,
    E2: EventStream,
    E3: EventStream,
    E4: EventStream,
    E5: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2,
    _ eventStream3: E3,
    _ eventStream4: E4,
    _ eventStream5: E5
) -> ZipEventStream5<E1, E2, E3, E4, E5> {
    .init(
        eventStream1,
        eventStream2,
        eventStream3,
        eventStream4,
        eventStream5
    )
}

public extension EventStream {
//    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//    func zip<each E: EventStream>(
//        _ others: repeat each E
//    ) -> ZipEventStream<Self, repeat each E> {
//        EventStreams.zip(self, repeat each others)
//    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func zip<
        E1: EventStream
    >(
        _ other1: E1
    ) -> ZipEventStream2<Self, E1> {
        EventStreams.zip(self, other1)
    }

//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func zip<
        E1: EventStream,
        E2: EventStream
    >(
        _ other1: E1,
        _ other2: E2
    ) -> ZipEventStream3<Self, E1, E2> {
        EventStreams.zip(self, other1, other2)
    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func zip<
        E1: EventStream,
        E2: EventStream,
        E3: EventStream
    >(
        _ other1: E1,
        _ other2: E2,
        _ other3: E3
    ) -> ZipEventStream4<Self, E1, E2, E3> {
        EventStreams.zip(self, other1, other2, other3)
    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func zip<
        E1: EventStream,
        E2: EventStream,
        E3: EventStream,
        E4: EventStream
    >(
        _ other1: E1,
        _ other2: E2,
        _ other3: E3,
        _ other4: E4
    ) -> ZipEventStream5<Self, E1, E2, E3, E4> {
        EventStreams.zip(self, other1, other2, other3, other4)
    }
}

public extension Collection where Element: EventStream {
    func zip() -> CollectionZipEventStream<Self> {
        .init(
            sources: self
        )
    }
}

private extension Optional {
    struct IsNil: Error {}
    
    var tryUnwrap: Wrapped {
        get throws {
            if let self {
                return self
            } else {
                throw IsNil()
            }
        }
    }
}

func unwrap<each Ts>(_ values: (repeat (each Ts)?)) -> (repeat each Ts)? {
    do {
        return try (repeat (each values).tryUnwrap)
    } catch {
        return nil
    }
}

//private struct Subscriber<Source: EventStream>: EventStream{
//    init(
//        source: Source,
//        lock: Lock
//    ) {
//        self.lock = lock
//        
//        subscription = source
//            .subscribe { [channel, _value] value in
//                lock.lock()
//                _value.values.append(value)
//                channel.publish()
//            }
//            .autoCancel()
//            .share()
//    }
//    
//    var values: [Source.Value] {
//        get { _value.values }
//        nonmutating set { _value.values = newValue }
//    }
//
//    func subscribe(_ onValue: @escaping @Sendable (()) -> Void) -> SimpleChannel<Void>.Subscription {
//        channel.subscribe(onValue)
//    }
//    
//    private final class ValueRef: @unchecked Sendable {
//        var values: [Source.Value] = []
//    }
//    
//    private let lock: Lock
//    private let subscription: SharedAutoSubscription
//    
//    private let channel = SimpleChannel<Void>()
//    private let _value = ValueRef()
//}

//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public struct ZipEventStream<each Sources: EventStream>: EventStream {
//    public typealias Value = (repeat (each Sources).Value)
//    
//    init(
//        _ sources: repeat each Sources
//    ) {
//        self.sources = (repeat each sources)
//        self.subscribers = (repeat Subscriber(source: (each sources), lock: lock))
//
//        self.subscription = aggregate(subscriptions: repeat (each subscribers).subscribe { @Sendable [subscribers, channel, lock] in
//            let values = (repeat (each subscribers).values.first)
//            
//            let readyValues = unwrap(values)
//   
//            if readyValues != nil {
//                _ = (repeat (each subscribers).values.removeFirst())
//            }
//            
//            lock.unlock()
//            
//            if let readyValues {
//                 channel.publish(readyValues)
//            }
//        })
//            .autoCancel()
//            .share()
//    }
//        
//    public let sources: (repeat each Sources)
//    
//    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
//        channel.subscribe(onValue)
//    }
//    
//    private let channel = SimpleChannel<Value>()
//    private let subscribers: (repeat Subscriber<each Sources>)
//    private let subscription: SharedAutoSubscription
//    
//    private let lock = Lock()
//}

public struct ZipEventStream2<
    Source1: EventStream,
    Source2: EventStream
>: EventStream {
    public typealias Value = (Source1.Value, Source2.Value)
    
    init(
        _ source1: Source1,
        _ source2: Source2
    ) {
        self.sources = (source1, source2)

        let update: @Sendable ((inout Values) -> Void) -> Void = { [channel, _values] updateValues in
            let readyValues = _values.write { values -> Value? in
                updateValues(&values)
                
                if let value1 = values.0.first, let value2 = values.1.first {
                    values.0.removeFirst()
                    values.1.removeFirst()
                    return (value1, value2)
                } else {
                    return nil
                }
            }
            
            if let readyValues {
                channel.publish(readyValues)
            }
        }

        let subscription1 = source1
            .subscribe { value in
                update { values in values.0.append(value) }
            }
        
        let subscription2 = source2
            .subscribe { value in
                update { values in values.1.append(value) }
            }
        
        subscription = aggregate(subscriptions: subscription1, subscription2)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private typealias Values = ([Source1.Value], [Source2.Value])
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
    
    private let _values = Synchronized<Values>(wrappedValue: ([], []))
}

public struct ZipEventStream3<
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream
>: EventStream {
    public typealias Value = (Source1.Value, Source2.Value, Source3.Value)
    
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3
    ) {
        self.sources = (source1, source2, source3)

        let update: @Sendable ((inout Values) -> Void) -> Void = { [channel, _values] updateValues in
            let readyValues = _values.write { values -> Value? in
                updateValues(&values)
                
                if let value1 = values.0.first, let value2 = values.1.first, let value3 = values.2.first {
                    values.0.removeFirst()
                    values.1.removeFirst()
                    values.2.removeFirst()
                    return (value1, value2, value3)
                } else {
                    return nil
                }
            }
            
            if let readyValues {
                channel.publish(readyValues)
            }
        }

        let subscription1 = source1
            .subscribe { value in
                update { values in values.0.append(value) }
            }
        
        let subscription2 = source2
            .subscribe { value in
                update { values in values.1.append(value) }
            }
        
        let subscription3 = source3
            .subscribe { value in
                update { values in values.2.append(value) }
            }
        
        subscription = aggregate(subscriptions: subscription1, subscription2, subscription3)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private typealias Values = ([Source1.Value], [Source2.Value], [Source3.Value])
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
    
    private let _values = Synchronized<Values>(wrappedValue: ([], [], []))
}

public struct ZipEventStream4<
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream,
    Source4: EventStream
>: EventStream {
    public typealias Value = (Source1.Value, Source2.Value, Source3.Value, Source4.Value)
    
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3,
        _ source4: Source4
    ) {
        self.sources = (source1, source2, source3, source4)
        
        let update: @Sendable ((inout Values) -> Void) -> Void = { [channel, _values] updateValues in
            let readyValues = _values.write { values -> Value? in
                updateValues(&values)
                
                if let value1 = values.0.first, let value2 = values.1.first, let value3 = values.2.first, let value4 = values.3.first {
                    values.0.removeFirst()
                    values.1.removeFirst()
                    values.2.removeFirst()
                    values.3.removeFirst()
                    return (value1, value2, value3, value4)
                } else {
                    return nil
                }
            }
            
            if let readyValues {
                channel.publish(readyValues)
            }
        }
        
        let subscription1 = source1
            .subscribe { value in
                update { values in values.0.append(value) }
            }
        
        let subscription2 = source2
            .subscribe { value in
                update { values in values.1.append(value) }
            }
        
        let subscription3 = source3
            .subscribe { value in
                update { values in values.2.append(value) }
            }
        
        let subscription4 = source4
            .subscribe { value in
                update { values in values.3.append(value) }
            }
        
        subscription = aggregate(subscriptions: subscription1, subscription2, subscription3, subscription4)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3, Source4)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private typealias Values = ([Source1.Value], [Source2.Value], [Source3.Value], [Source4.Value])
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
    
    private let _values = Synchronized<Values>(wrappedValue: ([], [], [], []))
}

public struct ZipEventStream5<
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream,
    Source4: EventStream,
    Source5: EventStream
>: EventStream {
    public typealias Value = (Source1.Value, Source2.Value, Source3.Value, Source4.Value, Source5.Value)
    
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3,
        _ source4: Source4,
        _ source5: Source5
    ) {
        self.sources = (source1, source2, source3, source4, source5)

        let update: @Sendable ((inout Values) -> Void) -> Void = { [channel, _values] updateValues in
            let readyValues = _values.write { values -> Value? in
                updateValues(&values)
                
                if let value1 = values.0.first, let value2 = values.1.first, let value3 = values.2.first, let value4 = values.3.first, let value5 = values.4.first {
                    values.0.removeFirst()
                    values.1.removeFirst()
                    values.2.removeFirst()
                    values.3.removeFirst()
                    values.4.removeFirst()
                    return (value1, value2, value3, value4, value5)
                } else {
                    return nil
                }
            }
            
            if let readyValues {
                channel.publish(readyValues)
            }
        }

        let subscription1 = source1
            .subscribe { value in
                update { values in values.0.append(value) }
            }
        
        let subscription2 = source2
            .subscribe { value in
                update { values in values.1.append(value) }
            }
        
        let subscription3 = source3
            .subscribe { value in
                update { values in values.2.append(value) }
            }
        
        let subscription4 = source4
            .subscribe { value in
                update { values in values.3.append(value) }
            }
        
        let subscription5 = source5
            .subscribe { value in
                update { values in values.4.append(value) }
            }
        
        subscription = aggregate(subscriptions: subscription1, subscription2, subscription3, subscription4, subscription5)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3, Source4, Source5)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private typealias Values = ([Source1.Value], [Source2.Value], [Source3.Value], [Source4.Value], [Source5.Value])
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
    
    private let _values = Synchronized<Values>(wrappedValue: ([], [], [], [], []))
}

public struct CollectionZipEventStream<
    Sources: Collection
>: EventStream where Sources.Element: EventStream {
    public typealias Value = [Sources.Element.Value]
    
    init(
        sources: Sources
    ) {
        _sources = .init(wrappedValue: sources)
        _values = .init(wrappedValue: .init(repeating: [], count: sources.count))
        
        subscription = sources
            .enumerated()
            .map { [channel, _values] index, sourceStream in
                sourceStream
                    .subscribe { value in
                        let values = _values.write { values -> Value? in
                            values[index].append(value)

                            let readyValues = values
                                .compactMap(\.first)
                            
                            if readyValues.count == values.count {
                                values.mutableForEach { values in values.removeFirst() }
                                return readyValues
                            } else {
                                return nil
                            }
                        }

                        if let values = values {
                            channel.publish(values)
                        }
                    }
            }
            .aggregated
            .autoCancel()
            .share()
    }

    public var sources: Sources { _sources.wrappedValue }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }

    private let channel = SimpleChannel<Value>()
    private let _sources: Synchronized<Sources>
    private let _values: Synchronized<[[Sources.Element.Value]]>
    private let subscription: SharedAutoSubscription
}
