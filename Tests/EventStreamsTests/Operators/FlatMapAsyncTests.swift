//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

import Observer
@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class FlatMapAsyncTests: XCTestCase {

    class Results {

        var result = Set<String>()
    }

    func testFlatMapAsync() async throws {

        let source = SimpleChannel<Int>()

        let testEvents = Set<Int>(0..<10)

        let innerSources: [SimpleChannel<String>] = testEvents.map { _ in

            SimpleChannel<String>()
        }

        let innerStreams = innerSources.map { innerSource in

            innerSource.asStream()
        }

        let asyncTransform: (Int) async -> EventStream<String> = { index in

            try! await Task.sleep(nanoseconds: UInt64(1e3))

            return innerStreams[index]
        }

        var expectedEvents = Set<String>()

        let sourceStream = source.asStream()
        let flatMappedStream = sourceStream.flatMapAsync(asyncTransform)

        let receivedEvents = Results()
        
        let subscription = flatMappedStream.subscribe { (event: String) in

            DispatchQueue.main.async {

                receivedEvents.result.insert(event)
            }
        }

        for event in testEvents {

            let innerEvents = (0..<10).map { index in

                "\(event)-\(index)"
            }

            let innerSource = innerSources[event]

            innerSource.publish("Shouldn't be there")

            source.publish(event)

            try! await Task.sleep(nanoseconds: UInt64(1e5))

            for innerEvent in innerEvents {
                innerSource.publish(innerEvent)
                expectedEvents.insert(innerEvent)
            }
        }

        for (index, innerSource) in innerSources.enumerated() {

            for innerIndex in 0..<10 {

                let additionalEvent = "Additional event \(innerIndex) from source \(index)"
                innerSource.publish(additionalEvent)
                expectedEvents.insert((additionalEvent))
            }
        }

        try await Task.sleep(nanoseconds: UInt64(3e9))

        XCTAssertEqual(receivedEvents.result, expectedEvents)

        withExtendedLifetime(subscription) { }
    }
}
