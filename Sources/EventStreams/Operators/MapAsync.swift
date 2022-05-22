//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func mapAsync<Result>(_ transform: @escaping (Value) async -> Result) -> EventStream<Result> {

        mapAsync { value, _ in
            
            Event<Result>(await transform(value))
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value, Date) async -> Result) -> EventStream<Result> {

        mapAsync { value, time in
            
            Event<Result>(await transform(value, time))
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value) async -> Event<Result>) -> EventStream<Result> {

        mapAsync { value, _ in

            await transform(value)
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value, Date) async -> Event<Result>) -> EventStream<Result> {

        self.map { (value, time) -> Task<Event<Result>, Never> in Task { await transform(value, time) } }
                .await()
    }

    public func mapAsync<ResultValue>(_ transform: @escaping (Value) async throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        mapAsync { value, _ in

            Event<ResultValue>(try await transform(value))
        }
    }

    public func mapAsync<ResultValue>(_ transform: @escaping (Value, Date) async throws -> ResultValue) -> EventStream<Result<ResultValue, Error>> {

        mapAsync { value, time in

            Event<ResultValue>(try await transform(value, time))
        }
    }

    public func mapAsync<ResultValue>(_ transform: @escaping (Value) async throws -> Event<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        mapAsync { value, _ in

            try await transform(value)
        }
    }

    public func mapAsync<ResultValue>(_ transform: @escaping (Value, Date) async throws -> Event<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        self.map { (value, time) -> Task<Event<ResultValue>, Error> in Task { try await transform(value, time) } }
                .await()
    }
}