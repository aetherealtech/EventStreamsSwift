//
//  Created by Daniel Coleman on 1/9/22.
//

public extension EventStream {
    func compactMap<Result>(
        _ transform: @escaping @Sendable (Value) -> Result?
    ) -> CompactEventStream<Result, MapEventStream<Self, Result?>> {
        self
            .map(transform)
            .compact()
    }
}
