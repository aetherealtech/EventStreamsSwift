//
//  Created by Daniel Coleman on 11/18/21.
//

#if !os(macOS) && !os(watchOS)

import Assertions
import XCTest
import Observer
import Synchronization

@testable import EventStreams

final class UIGestureRecognizerTests: XCTestCase {
    func testEventStream() throws {
        // TODO: Decide the best way to test this
    }
}

#endif
