//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

public struct Timestamped<Value> {

    public init(
        _ value: Value,
        time: Date = Date()
    ) {

        self.value = value
        self.time = time
    }

    public let value: Value
    public let time: Date
}

extension Timestamped: Equatable where Value: Equatable {

}

extension Timestamped: Hashable where Value: Hashable {

}

extension EventStream {

    public func timestamped() -> EventStream<Timestamped<Value>> {

        map { value in

            Timestamped<Value>(value)
        }
    }
}
