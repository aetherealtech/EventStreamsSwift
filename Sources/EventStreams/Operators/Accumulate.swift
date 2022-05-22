//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func accumulate<Result>(
        initialValue: Result,
        _ accumulator: @escaping (Result, Value) -> Result
    ) -> EventStream<Result> {

        var current = initialValue

        return self
                .map { value -> Result in

                    current = accumulator(current, value)
                    return current
                }
    }
}
