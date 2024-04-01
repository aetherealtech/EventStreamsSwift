////
////  Created by Daniel Coleman on 1/9/22.
////
//
//import Foundation
//import Observer
//import Scheduling
//
//public func sequence<Value, ValueAndTime, Values: Sequence>(
//    values: some Sequence<ValueAndTime>,
//    getValue: @escaping (ValueAndTime) -> Value,
//    getTime: @escaping (ValueAndTime) -> Date,
//    on scheduler: some Scheduler = DispatchQueue.global()
//) -> EventStream<Value> {
//    sch
//    SequenceEventStream(
//        values: values,
//        getValue: getValue,
//        getTime: getTime,
//        scheduler: scheduler
//    )
//}
//
//public func sequence<Value, Values: Sequence>(
//    values: some Sequence<(Value, Date)>,
//    on scheduler: Scheduler = DispatchQueue.global()
//) -> EventStream<Value> {
//
//    sequence(
//        values: values,
//        getValue: { event in event.0 },
//        getTime: { event in event.1 },
//        on: scheduler
//    )
//}
//
//public func timer<FireTimes: Sequence>(
//    times: FireTimes,
//    on scheduler: Scheduler = DispatchQueue.global()
//) -> EventStream<Void> where FireTimes.Element == Date {
//
//    sequence(
//        values: times,
//        getValue: { _ in },
//        getTime: { time in time },
//        on: scheduler
//    )
//}
//
//public struct SequenceEventStream<
//    Value,
//    ValueAndTime,
//    Values: Sequence<ValueAndTime>
//>: EventStream
//{
//    init(
//        values: Values,
//        getValue: @escaping (ValueAndTime) -> Value,
//        getTime: @escaping (ValueAndTime) -> Date,
//        scheduler: Scheduler
//    ) {
//
//        let eventsChannel = SimpleChannel<Value>()
//
//        self.timer = scheduler.runTimer(
//            values: values,
//            getFireTime: getTime,
//            onFire: { valueAndTime in
//
//                eventsChannel.publish(getValue(valueAndTime))
//            },
//            onComplete: { }
//        )
//
//        super.init(
//            channel: eventsChannel
//        )
//    }
//    
//    public func subscribe(
//        _ onValue: @escaping @Sendable (Value) -> Void
//    ) -> some Subscription {
//        <#code#>
//    }
//
//    private let timer: Scheduling.Timer
//}
