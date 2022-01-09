//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension Collection where Element : EventStreamProtocol {

    public func merge() -> EventStream<Element.Payload> {

        let stream = EventStream<Element.Payload>()

        for element in self {
            stream.subscriptions.insert(element.subscribe(stream.publish))
        }

        return stream
    }
}

extension EventStream {

    public func merge(_ other: EventStream<Payload>) -> EventStream<Payload> {

        return [self, other].merge()
    }
}
