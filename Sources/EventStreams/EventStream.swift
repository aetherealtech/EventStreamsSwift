//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import Observer
import Scheduling
import Synchronization

public protocol EventStream<Value>: Sendable {
    associatedtype Value
    associatedtype Subscription: Observer.Subscription
    
    func subscribe(
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> Subscription
}

public extension EventStream where Value: Sendable {
    func subscribe(
        on scheduler: some Scheduler,
        _ onValue: @escaping @Sendable (Value) -> Void
    ) -> Subscription {
        subscribe { value in
            scheduler.run {
                onValue(value)
            }
        }
    }
}

public extension EventStream where Value == Void {
    func subscribe(
        _ onValue: @escaping @Sendable () -> Void
    ) -> Subscription {
        subscribe { _ in onValue() }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension EventStream where Value: Sendable {
    func subscribe(
        _ onValue: @escaping @Sendable (Value) async -> Void
    ) -> Subscription {
        subscribe { value in
            Task {
                await onValue(value)
            }
        }
    }
}
