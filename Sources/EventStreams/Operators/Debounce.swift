//
//  Created by Daniel Coleman on 1/9/22.
//

import Scheduling
import Synchronization

public extension EventStream {
    func debounce(
        tolerance: Duration
    ) -> MapEventStream<FilteredEventStream<MapEventStream<Self, Timestamped<Value>>>, Value> {
        @Synchronized
        var lastTime = Instant.distantPast

        return self
            .timestamped
            .filter { [_lastTime] timestampedValue in
                let time = timestampedValue.time

                let timeInterval = _lastTime.write { lastTime in
                    let timeInterval = time - lastTime
                    lastTime = time
                    return timeInterval
                }

                return timeInterval >= tolerance
            }
            .map { timestamped in timestamped.value }
    }
}
