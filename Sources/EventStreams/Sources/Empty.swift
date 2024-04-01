//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

public func empty<Value>() -> Empty<Value> {
    .init()
}

public struct Empty<Value>: EventStream {
    public struct Subscription: Observer.Subscription {
        public func cancel() {}
    }
    
    public func subscribe(_ onValue: @escaping (Value) -> Void) -> Subscription {
        .init()
    }
}
