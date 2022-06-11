  //
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import CoreExtensions

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

        super.init(
            channel: channel
        )

        source1
            .subscribe { [weak self] v1 in

                self?.update { values in
                    values.first = v1
                }
            }
            .store(in: &subscriptions)

        source2
            .subscribe { [weak self] v2 in

                self?.update { values in
                    values.second = v2
                }
            }
            .store(in: &subscriptions)
    }

    private typealias Values = (first: Value1?, second: Value2?)

    private let source1: EventStream<Value1>
    private let source2: EventStream<Value2>

    private let channel = SimpleChannel<Value>()

    private var values: Atomic<Values> = Atomic((nil, nil))

    private var subscriptions = Set<Subscription>()

    private func update(updater: (inout Values) -> Void) {

        let values = values.exclusiveLock { values -> Value? in
            updater(&values)

            if let value1 = values.first, let value2 = values.second {
                let current = (value1, value2)
                values = (nil, nil)
                return current
            }

            return nil
        }

        if let values = values {

            channel.publish(values)
        }
    }
}

class ArrayZipEventStream<Value> : EventStream<[Value]>
{
    init(
        sources: [EventStream<Value>]
    ) {
        
        self.sources = sources

        self.values = Atomic<[Value?]>(Array(repeating: nil, count: sources.count))

        super.init(
            channel: channel
        )

        sources.enumerated().forEach { index, sourceStream in

            sourceStream
                .subscribe { [weak self] value in

                    self?.update { values in
                        values[index] = value
                    }
                }
                .store(in: &subscriptions)
        }
    }

    private let sources: [EventStream<Value>]

    private let channel = SimpleChannel<[Value]>()

    private var values: Atomic<[Value?]>

    private var subscriptions = Set<Subscription>()

    private func update(updater: (inout [Value?]) -> Void) {

        let values = values.exclusiveLock { values -> [Value]? in
            updater(&values)

            let readyValues = values.compactMap { value in value }
            if readyValues.count == values.count {

                values = Array(repeating: nil, count: sources.count)
                return readyValues
            }

            return nil
        }

        if let values = values {

            channel.publish(values)
        }
    }
}
