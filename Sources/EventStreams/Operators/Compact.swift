//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions

extension EventStream {

    public func compact<WrappedValue>() -> EventStream<Value.Wrapped> where Value == Optional<WrappedValue> {
        
        self
            .filter { value in value != nil }
            .map { value in value.unsafelyUnwrapped }
    }
}
