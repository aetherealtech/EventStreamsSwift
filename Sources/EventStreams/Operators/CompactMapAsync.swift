//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func compactMapAsync<Result>(_ transform: @escaping (Value) async -> Result?) -> EventStream<Result> {

        self
            .mapAsync(transform)
            .compact()
    }

    public func compactMapAsync<ResultValue>(_ transform: @escaping (Value) async throws -> ResultValue?) -> EventStream<Result<ResultValue, Error>> {

        self
            .mapAsync(transform)
            .map { result -> Result<ResultValue, Error>? in

                switch result {

                case .success(let value):
                    return value.map { value in Result<ResultValue, Error>.success(value) }

                case .failure(let error):
                    return .failure(error)
                }
            }
            .compact()
    }
}
