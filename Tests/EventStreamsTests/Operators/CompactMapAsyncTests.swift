//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class CompactMapAsyncTests: XCTestCase {

    class Results {

        var result = Set<String>()
    }

    func testCompactMapAsync() async throws {
        
        let source = SimpleChannel<Int>()
        
        let testEvents = Set<Int>(0..<10)

        let transform: (Int) -> String? = { value in

            value.isMultiple(of: 3) ? "\(value)" : nil
        }

        let asyncTransform: (Int) async -> String? = { value in

            try! await Task.sleep(nanoseconds: UInt64(1e3))

            return transform(value)
        }
        
        let expectedEvents = Set<String>(testEvents.compactMap(transform))
        
        let sourceStream = source.asStream()
        let mappedStream = sourceStream.compactMapAsync(asyncTransform)
        
        let receivedEvents = Results()
        
        let subscription = mappedStream.subscribe { (event: String) in

            DispatchQueue.main.async {

                receivedEvents.result.insert(event)
            }
        }
        
        for event in testEvents {
            source.publish(event)
        }

        try await Task.sleep(nanoseconds: UInt64(1e9))

        XCTAssertEqual(receivedEvents.result, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}