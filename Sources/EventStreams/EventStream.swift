//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import Observer

public protocol EventStreamProtocol {

    associatedtype Payload

    func subscribe(_ handler: @escaping (Payload) -> Void) -> Subscription
}

final public class EventStream<Payload> : EventStreamProtocol {

    internal init() {

        self.channel = SimpleChannel().asTypedChannel()
    }

    public convenience init<Source: TypedChannel>(source: Source) where Source.Event == Payload {

        self.init()
        
        source.subscribe { [weak self] event in self?.publish(event) }
            .store(in: &subscriptions)
    }

    public func subscribe(_ handler: @escaping (Payload) -> Void) -> Subscription {

        subscribeWithTime { event in handler(event.payload) }
    }

    internal func subscribeWithTime(_ handler: @escaping (Event) -> Void) -> Subscription {

        channel.subscribe(handler)
    }
    
    internal func publish(_ payload: Payload) {

        publish((payload: payload, time: Date()))
    }

    internal func publish(_ event: Event) {

        channel.publish(event)
    }

    internal typealias Event = (payload: Payload, time: Date)
    
    internal let channel: AnyTypedChannel<Event>
    internal var subscriptions = Set<Subscription>()
}
