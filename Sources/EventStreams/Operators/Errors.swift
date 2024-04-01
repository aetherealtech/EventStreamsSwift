//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation
import Observer
import ResultExtensions

public extension EventStream {
    func mapValues<InSuccess, OutSuccess, Failure: Error>(
        _ transform: @escaping @Sendable (InSuccess) -> OutSuccess
    ) -> MapEventStream<Self, Result<OutSuccess, Failure>> where Value == Result<InSuccess, Failure> {

        self
            .map { result in 
                result
                    .map(transform)
            }
    }

    func tryMapValues<InSuccess, OutSuccess>(
        _ transform: @escaping @Sendable (InSuccess) throws -> OutSuccess
    ) -> MapEventStream<Self, Result<OutSuccess, any Error>> where Value == Result<InSuccess, any Error> {
        self
            .map { result in 
                result
                    .tryMap(transform)
            }
    }

    func mapErrors<Success, InFailure: Error, OutFailure: Error>(
        _ transform: @escaping @Sendable (InFailure) -> OutFailure
    ) -> MapEventStream<Self, Result<Success, OutFailure>> where Value == Result<Success, InFailure> {
        self
            .map { result in result.mapError(transform) }
    }

    func tryMapErrors<Success, InFailure: Error>(
        _ transform: @escaping @Sendable (InFailure) throws -> Error
    ) -> MapEventStream<Self, Result<Success, any Error>> where Value == Result<Success, InFailure> {
        self
            .map { result in result.tryMapError(transform) }
    }

    func compactMapValues<InSuccess, OutSuccess, Failure: Error>(
        _ transform: @escaping @Sendable (InSuccess) -> OutSuccess?
    ) -> CompactEventStream<Result<OutSuccess, Failure>, MapEventStream<Self, Result<OutSuccess, Failure>?>> where Value == Result<InSuccess, Failure> {
        self
            .compactMap { result in
                result
                    .compactMap(transform)
            }
    }

    func tryCompactMapValues<InSuccess, OutSuccess>(
        _ transform: @escaping @Sendable (InSuccess) throws -> OutSuccess?
    ) -> CompactEventStream<Result<OutSuccess, any Error>, MapEventStream<Self, Result<OutSuccess, any Error>?>> where Value == Result<InSuccess, Error> {
        self
            .compactMap { result in
                result
                    .tryCompactMap(transform)
            }
    }

    func flatMapErrors<Success, InFailure: Error, OutFailure: Error>(
        _ transform: @escaping @Sendable (InFailure) -> Result<Success, OutFailure>
    ) -> MapEventStream<Self, Result<Success, OutFailure>> where Value == Result<Success, InFailure> {
        self
            .map { result in result.flatMapError(transform) }
    }

    func `catch`<Success, Failure: Error>(
        _ catcher: @escaping @Sendable (Failure) -> Success
    ) -> MapEventStream<Self, Success> where Value == Result<Success, Failure> {
        self
            .map { result in result.catch(catcher) }
    }

    func tryCatch<Success, Failure: Error>(
        _ catcher: @escaping @Sendable (Failure) throws -> Success
    ) -> MapEventStream<Self, Result<Success, any Error>> where Value == Result<Success, Failure> {
        self
            .map { result in result.tryCatch(catcher) }
    }

    func ignoreErrors<Success, Failure: Error>() -> CompactEventStream<Success, MapEventStream<Self, Success?>> where Value == Result<Success, Failure> {
        self
            .compactMap { result in try? result.get() }
    }
}
