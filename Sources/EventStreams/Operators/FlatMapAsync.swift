//
//  Created by Daniel Coleman on 1/9/22.
//

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream {
    func flatMap<InnerResult, OuterResult: EventStream<Task<InnerResult, Never>>>(
        _ transform: @escaping @Sendable (Value) -> OuterResult
    ) -> AwaitEventStream<InnerResult, FlattenEventStream<MapEventStream<Self, OuterResult>>> {
        self
            .flatMap(transform)
            .await()
    }

    func flatMap<InnerResult, OuterResult: EventStream<InnerResult>>(
        _ transform: @escaping @Sendable (Value) async -> OuterResult
    ) -> FlattenEventStream<AwaitEventStream<OuterResult, MapEventStream<Self, Task<OuterResult, Never>>>> where Value: Sendable {
        self
            .map(transform)
            .flatten()
    }

    func flatMap<InnerResult, OuterResult: EventStream<Task<InnerResult, any Error>>>(
        _ transform: @escaping @Sendable (Value) -> OuterResult
    ) -> TryAwaitEventStream<InnerResult, FlattenEventStream<MapEventStream<Self, OuterResult>>> {
        self
            .flatMap(transform)
            .await()
    }

    func flatMap<InnerResult, OuterResult: EventStream<InnerResult>>(
        _ transform: @escaping @Sendable (Value) async throws -> OuterResult
    ) -> TryFlatMapEventStream<TryAwaitEventStream<OuterResult, MapEventStream<Self, Task<OuterResult, any Error>>>, OuterResult> where Value: Sendable {
        self
            .map { value in Task { try await transform(value) } }
            .await()
            .flatMap { result in try result.get() }
    }
}
