//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream where Payload : EventStreamProtocol {

    public func flatten() -> EventStream<Payload.Payload> {

        let stream = EventStream<Payload.Payload>()

        stream.subscriptions.insert(subscribe { innerStream in

            stream.subscriptions.insert(innerStream.subscribe(stream.publish))
        })

        return stream
    }
}
