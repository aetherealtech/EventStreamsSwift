//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

public extension EventStream {
    func difference<Result>(
        initialValue: Value? = nil,
        _ differentiator: @escaping @Sendable (Value, Value) -> Result
    ) -> MapEventStream<CollectEventStream<Self>, Result> {
        self
            .collect(count: 2, stride: 1)
            .map { values -> Result in
                let previous = values[0]
                let current = values[1]
                
                return differentiator(current, previous)
            }
    }
}
