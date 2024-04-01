//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

public struct Timestamped<Value> {
    public init(
        _ value: Value,
        time: Instant = .now
    ) {
        self.value = value
        self.time = time
    }

    public let value: Value
    public let time: Instant
}

extension Timestamped: Equatable where Value: Equatable {}
extension Timestamped: Hashable where Value: Hashable {}
extension Timestamped: Sendable where Value: Sendable {}

public extension EventStream {
    var timestamped: MapEventStream<Self, Timestamped<Value>> {
        map { value in

            Timestamped<Value>(value)
        }
    }

    func values<ActualValue>() -> MapEventStream<Self, ActualValue> where Value == Timestamped<ActualValue> {
        map(\.value)
    }
}

public extension EventStream {
    func filter(_ condition: @escaping @Sendable (Value, Instant) -> Bool) -> MapEventStream<FilteredEventStream<MapEventStream<Self, Timestamped<Value>>>, Value> {
        self
            .timestamped
            .filter { timestamped in condition(timestamped.value, timestamped.time) }
            .values()
    }

    func map<Result>(_ transform: @escaping @Sendable (Value, Instant) -> Result) -> MapEventStream<MapEventStream<Self, Timestamped<Value>>, Result> {
        self
            .timestamped
            .map { timestamped in transform(timestamped.value, timestamped.time) }
    }
}
