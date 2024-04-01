//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public func merge<Value, each E: EventStream>(
//    _ eventStreams: repeat each E
//) -> MergeEventStream<Value, repeat each E> where E.Value == Value {
//    .init(
//        eventStreams
//    )
//}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func merge<
    Value,
    E1: EventStream,
    E2: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2
) -> MergeEventStream2<Value, E1, E2> {
    .init(
        eventStream1,
        eventStream2
    )
}

//@available(macOS, obsoleted: 14.0)
//@available(iOS, obsoleted: 17.0)
//@available(tvOS, obsoleted: 17.0)
//@available(watchOS, obsoleted: 10.0)
public func merge<
    Value,
    E1: EventStream,
    E2: EventStream,
    E3: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2,
    _ eventStream3: E3
) -> MergeEventStream3<Value, E1, E2, E3> {
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
public func merge<
    Value,
    E1: EventStream,
    E2: EventStream,
    E3: EventStream,
    E4: EventStream
>(
    _ eventStream1: E1,
    _ eventStream2: E2,
    _ eventStream3: E3,
    _ eventStream4: E4
) -> MergeEventStream4<Value, E1, E2, E3, E4> {
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
public func merge<
    Value,
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
) -> MergeEventStream5<Value, E1, E2, E3, E4, E5> {
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
//    func merge<Value, each E: EventStream>(
//        _ others: repeat each E
//    ) -> MergeEventStream<Value, Self, each E> {
//        EventStreams.merge(self, repeat each others)
//    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func merge<
        Value,
        E1: EventStream
    >(
        _ other1: E1
    ) -> MergeEventStream2<Value, Self, E1> {
        EventStreams.merge(self, other1)
    }

//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func merge<
        Value,
        E1: EventStream,
        E2: EventStream
    >(
        _ other1: E1,
        _ other2: E2
    ) -> MergeEventStream3<Value, Self, E1, E2> {
        EventStreams.merge(self, other1, other2)
    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func merge<
        Value,
        E1: EventStream,
        E2: EventStream,
        E3: EventStream
    >(
        _ other1: E1,
        _ other2: E2,
        _ other3: E3
    ) -> MergeEventStream4<Value, Self, E1, E2, E3> {
        EventStreams.merge(self, other1, other2, other3)
    }
    
//    @available(macOS, obsoleted: 14.0)
//    @available(iOS, obsoleted: 17.0)
//    @available(tvOS, obsoleted: 17.0)
//    @available(watchOS, obsoleted: 10.0)
    func merge<
        Value,
        E1: EventStream,
        E2: EventStream,
        E3: EventStream,
        E4: EventStream
    >(
        _ other1: E1,
        _ other2: E2,
        _ other3: E3,
        _ other4: E4
    ) -> MergeEventStream5<Value, Self, E1, E2, E3, E4> {
        EventStreams.merge(self, other1, other2, other3, other4)
    }
}

public extension Collection where Element: EventStream {
    func merge() -> CollectionMergeEventStream<Self> {
        .init(
            sources: self
        )
    }
}

//@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, *)
//public struct MergeEventStream<Value, each Sources: EventStream>: EventStream where repeat (each Sources).Value == Value {
//    init(
//        _ sources: repeat each Sources
//    ) {
//        self.sources = (repeat each sources)
//
//        let subscriptions = (repeat (each sources).subscribe { [channel] value in channel.publish(value) } )
//                
//        self.subscription = aggregate(subscriptions: repeat each subscriptions)
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
//    private let subscription: SharedAutoSubscription
//}

public struct MergeEventStream2<
    Value,
    Source1: EventStream,
    Source2: EventStream
>: EventStream where Source1.Value == Value, Source2.Value == Value {
    init(
        _ source1: Source1,
        _ source2: Source2
    ) {
        self.sources = (source1, source2)
        
        let publish: @Sendable (Value) -> Void = { [channel] value in channel.publish(value) }
        
        let subscription1 = source1
            .subscribe(publish)
        
        let subscription2 = source2
            .subscribe(publish)
                
        self.subscription = aggregate(subscriptions: subscription1, subscription2)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}

public struct MergeEventStream3<
    Value,
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream
>: EventStream where Source1.Value == Value, Source2.Value == Value, Source3.Value == Value {
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3
    ) {
        self.sources = (source1, source2, source3)

        let publish: @Sendable (Value) -> Void = { [channel] value in channel.publish(value) }

        let subscription1 = source1
            .subscribe(publish)
        
        let subscription2 = source2
            .subscribe(publish)
        
        let subscription3 = source3
            .subscribe(publish)
                
        self.subscription = aggregate(subscriptions: subscription1, subscription2, subscription3)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}

public struct MergeEventStream4<
    Value,
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream,
    Source4: EventStream
>: EventStream where Source1.Value == Value, Source2.Value == Value, Source3.Value == Value, Source4.Value == Value {
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3,
        _ source4: Source4
    ) {
        self.sources = (source1, source2, source3, source4)
        
        let publish: @Sendable (Value) -> Void = { [channel] value in channel.publish(value) }
        
        let subscription1 = source1
            .subscribe(publish)
        
        let subscription2 = source2
            .subscribe(publish)
        
        let subscription3 = source3
            .subscribe(publish)
        
        let subscription4 = source4
            .subscribe(publish)
                
        self.subscription = aggregate(subscriptions: subscription1, subscription2, subscription3, subscription4)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3, Source4)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}

public struct MergeEventStream5<
    Value,
    Source1: EventStream,
    Source2: EventStream,
    Source3: EventStream,
    Source4: EventStream,
    Source5: EventStream
>: EventStream where Source1.Value == Value, Source2.Value == Value, Source3.Value == Value, Source4.Value == Value, Source5.Value == Value {
    init(
        _ source1: Source1,
        _ source2: Source2,
        _ source3: Source3,
        _ source4: Source4,
        _ source5: Source5
    ) {
        self.sources = (source1, source2, source3, source4, source5)
        
        let publish: @Sendable (Value) -> Void = { [channel] value in channel.publish(value) }
        
        let subscription1 = source1
            .subscribe(publish)
        
        let subscription2 = source2
            .subscribe(publish)
        
        let subscription3 = source3
            .subscribe(publish)
        
        let subscription4 = source4
            .subscribe(publish)
        
        let subscription5 = source5
            .subscribe(publish)
                
        self.subscription = aggregate(subscriptions: subscription1, subscription2, subscription3, subscription4, subscription5)
            .autoCancel()
            .share()
    }
        
    public let sources: (Source1, Source2, Source3, Source4, Source5)
    
    public func subscribe(_ onValue: @escaping @Sendable (Value) -> Void) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }
    
    private let channel = SimpleChannel<Value>()
    private let subscription: SharedAutoSubscription
}


public struct CollectionMergeEventStream<
    Sources: Collection
>: EventStream where Sources.Element: EventStream {
    public typealias Value = Sources.Element.Value
    
    init(
        sources: Sources
    ) {
        _sources = .init(wrappedValue: sources)
        
        subscriptions = sources
            .map { [channel] sourceStream in
                sourceStream
                    .subscribe { value in channel.publish(value) }
                    .autoCancel()
                    .share()
            }
    }

    public var sources: Sources { _sources.wrappedValue }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> SimpleChannel<Value>.Subscription {
        channel.subscribe(onValue)
    }

    private let channel = SimpleChannel<Value>()
    private let _sources: Synchronized<Sources>
    private let subscriptions: [SharedAutoSubscription]
}
