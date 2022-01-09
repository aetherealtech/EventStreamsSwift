//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func combineLatest<Other>(
        _ other: EventStream<Other>
    ) -> EventStream<(Payload, Other)> {

        var first: Payload?
        var second: Other?

        let stream = EventStream<(Payload, Other)>()

        let send: () -> Void = {

            if let f = first, let s = second {
                stream.publish((f, s))
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

    public func combineLatest<Other1, Other2>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>
    ) -> EventStream<(Payload, Other1, Other2)> {

        self
            .combineLatest(other1)
            .combineLatest(other2)
            .map { first, last in (first.0, first.1, last) }
    }

    public func combineLatest<Other1, Other2, Other3>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>
    ) -> EventStream<(Payload, Other1, Other2, Other3)> {

        self
            .combineLatest(other1, other2)
            .combineLatest(other3)
            .map { first, last in (first.0, first.1, first.2, last) }
    }

    public func combineLatest<Other1, Other2, Other3, Other4>(
        _ other1: EventStream<Other1>,
        _ other2: EventStream<Other2>,
        _ other3: EventStream<Other3>,
        _ other4: EventStream<Other4>
    ) -> EventStream<(Payload, Other1, Other2, Other3, Other4)> {

        self
            .combineLatest(other1, other2, other3)
            .combineLatest(other4)
            .map { first, last in (first.0, first.1, first.2, first.3, last) }
    }
}

extension Array where Element: EventStreamProtocol {

    public func combineLatest() -> EventStream<[Element.Payload]> {

        var values: [Element.Payload?] = self.map { _ in nil }

        let stream = EventStream<[Element.Payload]>()

        let send: () -> Void = {

            let readyValues = values.compactMap { value in value }
            guard readyValues.count == values.count else { return }
            
            stream.publish(readyValues)
        }

        self.enumerated().forEach { index, sourceStream in

            stream.subscriptions.insert(sourceStream.subscribe { event in
                
                values[index] = event
                send()
            })
        }

        return stream
    }
}
