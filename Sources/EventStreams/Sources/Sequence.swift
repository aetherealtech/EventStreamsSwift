//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling
import CoreExtensions

extension EventStream {

    public static func sequence<Value, ValueAndTime, Values: Sequence>(
        values: Values,
        getValue: @escaping (ValueAndTime) -> Value,
        getTime: @escaping (ValueAndTime) -> Date,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> where Values.Element == ValueAndTime {

        SequenceEventStream(
            values: values,
            getValue: getValue,
            getTime: getTime,
            scheduler: scheduler
        )
    }

    public static func sequence<Value, Values: Sequence>(
        values: Values,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Value> where Values.Element == Event<Value> {

        sequence(
            values: values,
            getValue: { event in event.value },
            getTime: { event in event.time },
            on: scheduler
        )
    }

    public static func timer<FireTimes: Sequence>(
        times: FireTimes,
        on scheduler: Scheduler = DispatchQueue.global()
    ) -> EventStream<Void> where FireTimes.Element == Date {

        sequence(
            values: times,
            getValue: { _ in },
            getTime: { time in time },
            on: scheduler
        )
    }
}

class SequenceEventStream<Value, ValueAndTime, Values: Sequence> : EventStream<Value> where Values.Element == ValueAndTime
{
    init(
        values: Values,
        getValue: @escaping (ValueAndTime) -> Value,
        getTime: @escaping (ValueAndTime) -> Date,
        scheduler: Scheduler
    ) {

        let eventsChannel = SimpleChannel<Event<Value>>()
        let completeChannel = SimpleChannel<Void>()

        self.timer = scheduler.runTimer(
            values: values,
            getFireTime: getTime,
            onFire: { valueAndTime in

                eventsChannel.publish(Event<Value>(getValue(valueAndTime), time: getTime(valueAndTime)))
            },
            onComplete: completeChannel.publish
        )

        super.init(
            eventChannel: eventsChannel,
            completeChannel: completeChannel
        )
    }

    private let timer: Scheduling.Timer
}