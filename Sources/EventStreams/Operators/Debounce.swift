//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func debounce(tolerance: TimeInterval) -> EventStream<Value> {

        var lastTime = Date(timeIntervalSince1970: 0)

        return self
            .timestamped()
            .filter { timestampedValue in

                let time = timestampedValue.time

                let timeInterval = time.timeIntervalSince(lastTime)
                lastTime = time

                return timeInterval >= tolerance
            }
            .map { timestamped in timestamped.value }
    }
}
