//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func compactMap<Result>(_ transform: @escaping (Value) -> Result?) -> EventStream<Result> {

        compactMap { value, date in
            
            transform(value)
        }
    }
    
    public func compactMap<Result>(_ transform: @escaping (Value, Date) -> Result?) -> EventStream<Result> {

        self
            .map(transform)
            .compact()
    }
}
