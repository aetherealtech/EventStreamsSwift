//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func zip<Other>(
        _ other: EventStream<Other>
    ) -> EventStream<(Payload, Other)> {

        var first: Payload?
        var second: Other?

        let stream = EventStream<(Payload, Other)>()

        let send: () -> Void = {

            if let f = first, let s = second {
                stream.publish((f, s))
                
                first = nil
                second = nil
            }
        }

        stream.subscriptions.insert(subscribe { event in

            first = event
            send()
        })

        stream.subscriptions.insert(other.subscribe { event in

            second = event
            send()
        })

        return stream
    }

    public func zip<Other1, Other2>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>
    ) -> EventStream<(Payload, Other1, Other2)> {

        self
            .zip(other1)
            .zip(other2)
            .map { first, last in (first.0, first.1, last) }
    }

    public func zip<Other1, Other2, Other3>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>
    ) -> EventStream<(Payload, Other1, Other2, Other3)> {

        self
            .zip(other1, other2)
            .zip(other3)
            .map { first, last in (first.0, first.1, first.2, last) }
    }

    public func zip<Other1, Other2, Other3, Other4>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>,
        _ other4: EventStream<Other4>
    ) -> EventStream<(Payload, Other1, Other2, Other3, Other4)> {

        self
            .zip(other1, other2, other3)
            .zip(other4)
            .map { first, last in (first.0, first.1, first.2, first.3, last) }
    }
}
