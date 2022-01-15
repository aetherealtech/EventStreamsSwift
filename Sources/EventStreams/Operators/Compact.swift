//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import CoreExtensions

extension EventStream {

    public func compact() -> EventStream<Value.Wrapped> where Value: OptionalProtocol {
        
        self
            .filter { value in value != nil }
            .map { value in value.unsafelyUnwrapped }
    }
}
