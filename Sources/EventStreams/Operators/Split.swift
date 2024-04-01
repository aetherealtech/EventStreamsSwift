//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

public extension EventStream {
    func split(
        until: @escaping @Sendable (Value) -> Bool
    ) -> CollectUntilEventStream<Self> {
        collect(
            until: until,
            strideUntil: until
        )
    }
}

public extension EventStream where Value: Equatable & Sendable {
    func split(
        on splitValue: Value
    ) -> CollectUntilEventStream<Self> {
        split(
            until: { value in value == splitValue }
        )
    }
}
