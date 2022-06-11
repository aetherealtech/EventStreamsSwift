//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension SubChannel {

    public func asStream() -> EventStream<Value> {

        EventStream(channel: self)
    }
}
