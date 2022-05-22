//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer
import Scheduling

extension EventStream {

    public static func empty() -> EventStream<Value> {

        EventStream(
            channel: SimpleChannel<Event<Value>>()
        )
    }
}
