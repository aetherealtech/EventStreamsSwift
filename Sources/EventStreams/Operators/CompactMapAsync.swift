//
//  Created by Daniel Coleman on 1/9/22.
//

import ResultExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream where Value: Sendable {
    func compactMap<Result>(
        _ transform: @escaping @Sendable (Value) async -> Result?
    ) -> CompactEventStream<Result, AwaitEventStream<Result?, MapEventStream<Self, Task<Result?, Never>>>> {
        self
            .map(transform)
            .compact()
    }

    func compactMap<ResultValue>(
        _ transform: @escaping @Sendable (Value) async throws -> ResultValue?
    ) -> CompactEventStream<Result<ResultValue, any Error>, MapEventStream<TryAwaitEventStream<ResultValue?, MapEventStream<Self, Task<ResultValue?, any Error>>>, Result<ResultValue, any Error>?>> {
        self
            .map(transform)
            .map { result -> Result<ResultValue, Error>? in
                switch result {
                    case .success(let value): value.map { value in Result<ResultValue, Error>.success(value) }
                    case .failure(let error): .failure(error)
                }
            }
            .compact()
    }
}
