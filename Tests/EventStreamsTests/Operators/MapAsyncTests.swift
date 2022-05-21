//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class MapAsyncTests: XCTestCase {

    class Results {

        var result = Set<String>()
    }

    func testMapAsync() async throws {
        
        let source = SimpleChannel<Int>()
        
        let testEvents = Set<Int>(0..<10)
        
        let transform: (Int) -> String = { value in

            "\(value)"
        }

        let asyncTransform: (Int) async -> String = { value in

            try! await Task.sleep(nanoseconds: UInt64(1e3))

            return transform(value)
        }
        
        let expectedEvents = Set<String>(testEvents.map(transform))
        
        let sourceStream = source.asStream()
        let mappedStream = sourceStream.mapAsync(asyncTransform)
        
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