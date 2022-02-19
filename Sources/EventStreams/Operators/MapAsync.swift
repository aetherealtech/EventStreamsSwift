//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension EventStream {

    public func mapAsync<Result>(_ transform: @escaping (Value) async -> Result) -> EventStream<Result> {

        mapAsync { value, _ in
            
            Event<Result>(await transform(value))
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value, Date) async -> Result) -> EventStream<Result> {

        mapAsync { value, time in
            
            Event<Result>(await transform(value, time))
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value) async -> Event<Result>) -> EventStream<Result> {

        mapAsync { value, _ in

            await transform(value)
        }
    }
    
    public func mapAsync<Result>(_ transform: @escaping (Value, Date) async -> Event<Result>) -> EventStream<Result> {

        self.map { (value, time) -> Task<Event<Result>, Never> in Task { await transform(value, time) } }
                .await()
    }
}