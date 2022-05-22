//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func difference<Result>(
        initialValue: Value? = nil,
        _ differentiator: @escaping (Value, Value) -> Result
    ) -> EventStream<Result> {

        self
                .buffer(count: 2, stride: 1)
                .map { values -> Result in

                    let previous = values[0]
                    let current = values[1]

                    return differentiator(current, previous)
                }
    }
}
