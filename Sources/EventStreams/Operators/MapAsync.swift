//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func mapAsync<Result>(_ transform: @escaping (Value) async -> Result) -> EventStream<Result> {

        self
            .map { value -> Task<Result, Never> in Task { await transform(value) } }
            .await()
    }

    public func mapAsync<ResultValue>(_ transform: @escaping (Value) async throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        self
            .map { value -> Task<ResultValue, Error> in Task { try await transform(value) } }
            .await()
    }
}