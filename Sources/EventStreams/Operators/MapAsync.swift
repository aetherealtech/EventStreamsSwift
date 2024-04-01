//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream where Value: Sendable {
    func map<Result>(
        _ transform: @escaping @Sendable (Value) async -> Result
    ) -> AwaitEventStream<Result, MapEventStream<Self, Task<Result, Never>>> {
        self
            .map { value -> Task<Result, Never> in Task { await transform(value) } }
            .await()
    }

    func map<ResultValue>(
        _ transform: @escaping @Sendable (Value) async throws -> ResultValue
    ) -> TryAwaitEventStream<ResultValue, MapEventStream<Self, Task<ResultValue, any Error>>> {
        self
            .map { value -> Task<ResultValue, Error> in Task { try await transform(value) } }
            .await()
    }
}
