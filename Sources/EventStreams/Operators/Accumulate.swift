//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Synchronization

extension EventStream {
    public func accumulate<Result>(
        initialValue: Result,
        _ accumulator: @escaping @Sendable (Result, Value) -> Result
    ) -> MapEventStream<Self, Result> {
        @Synchronized
        var current = initialValue
        
        return self
            .map { [_current] value -> Result in
                _current.write { current in
                    current = accumulator(current, value)
                    return current
                }
            }
    }
}
