//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventStream {

    public func flatMapAsync<Result>(_ transform: @escaping (Value) -> EventStream<Task<Result, Never>>) -> EventStream<Result> {

        self
            .flatMap(transform)
            .await()
    }

    public func flatMapAsync<Result>(_ transform: @escaping (Value) async -> EventStream<Result>) -> EventStream<Result> {

        self
            .mapAsync(transform)
            .flatten()
    }

    public func flatMapAsync<ResultValue>(_ transform: @escaping (Value) -> EventStream<Task<ResultValue, Error>>) -> EventStream<Result<ResultValue, Error>> {

        self
            .flatMap(transform)
            .await()
    }

    public func flatMapAsync<ResultValue>(_ transform: @escaping (Value) async throws -> EventStream<ResultValue>) -> EventStream<Result<ResultValue, Error>> {

        self
            .mapAsync { value in Task { try await transform(value) } }
            .await()
            .flatMap { result in try result.get() }
    }
}
