//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func compactMap<Result>(_ transform: @escaping (Payload) -> Result?) -> EventStream<Result> {

        compactMap { payload, date in
            
            transform(payload)
        }
    }
    
    public func compactMap<Result>(_ transform: @escaping (Payload, Date) -> Result?) -> EventStream<Result> {

        self
            .map(transform)
            .compact()
    }
}
