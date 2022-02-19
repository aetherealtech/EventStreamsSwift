//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension EventStream {

    public func compactMapAsync<Result>(_ transform: @escaping (Value) async -> Result?) -> EventStream<Result> {

        compactMapAsync { value, date in
            
            await transform(value)
        }
    }
    
    public func compactMapAsync<Result>(_ transform: @escaping (Value, Date) async -> Result?) -> EventStream<Result> {

        self
            .mapAsync(transform)
            .compact()
    }
}
