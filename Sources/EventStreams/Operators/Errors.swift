//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation
import CoreExtensions
import Observer

extension EventStream {

    public func mapValues<InSuccess, OutSuccess, Failure: Error>(
        _ transform: @escaping (InSuccess) -> OutSuccess
    ) -> EventStream<Result<OutSuccess, Failure>> where Value == Result<InSuccess, Failure> {

        self
            .map { result in result

                .map(transform)
            }
    }

    public func tryMapValues<InSuccess, OutSuccess>(
        _ transform: @escaping (InSuccess) throws -> OutSuccess
    ) -> EventStream<Result<OutSuccess, Error>> where Value == Result<InSuccess, Error> {

        self
            .map { result in result

                .tryMap(transform)
            }
    }

    public func mapErrors<Success, InFailure: Error, OutFailure: Error>(
        _ transform: @escaping (InFailure) -> OutFailure
    ) -> EventStream<Result<Success, OutFailure>> where Value == Result<Success, InFailure> {

        self
            .map { result in result.mapError(transform) }
    }

    public func tryMapErrors<Success, InFailure: Error>(
        _ transform: @escaping (InFailure) throws -> Error
    ) -> EventStream<Result<Success, Error>> where Value == Result<Success, InFailure> {

        self
            .map { result in result.tryMapError(transform) }
    }

    public func compactMapValues<InSuccess, OutSuccess, Failure: Error>(
        _ transform: @escaping (InSuccess) -> OutSuccess?
    ) -> EventStream<Result<OutSuccess, Failure>> where Value == Result<InSuccess, Failure> {

        self
            .compactMap { result in

                result
                    .compactMap(transform)
            }
    }

    public func tryCompactMapValues<InSuccess, OutSuccess>(
        _ transform: @escaping (InSuccess) throws -> OutSuccess?
    ) -> EventStream<Result<OutSuccess, Error>> where Value == Result<InSuccess, Error> {

        self
            .compactMap { result in

                result
                    .tryCompactMap(transform)
            }
    }

    public func flatMapErrors<Success, InFailure: Error, OutFailure: Error>(
        _ transform: @escaping (InFailure) -> Result<Success, OutFailure>
    ) -> EventStream<Result<Success, OutFailure>> where Value == Result<Success, InFailure> {

        self
            .map { result in result.flatMapError(transform) }
    }

    public func `catch`<Success, Failure: Error>(
        _ catcher: @escaping (Failure) -> Success
    ) -> EventStream<Success> where Value == Result<Success, Failure> {

        self
            .map { result in result.catch(catcher) }
    }

    public func tryCatch<Success, Failure: Error>(
        _ catcher: @escaping (Failure) throws -> Success
    ) -> EventStream<Result<Success, Error>> where Value == Result<Success, Failure> {

        self
            .map { result in result.tryCatch(catcher) }
    }

    public func ignoreErrors<Success, Failure: Error>() -> EventStream<Success> where Value == Result<Success, Failure> {

        self
            .compactMap { result in try? result.get() }
    }
}
