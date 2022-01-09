//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func debounce(tolerance: TimeInterval) -> EventStream<Payload> {

        var lastTime = Date(timeIntervalSince1970: 0)

        return self.filter { payload, time in
            
            let timeInterval = time.timeIntervalSince(lastTime)
            lastTime = time

            return timeInterval >= tolerance
        }
    }
}
