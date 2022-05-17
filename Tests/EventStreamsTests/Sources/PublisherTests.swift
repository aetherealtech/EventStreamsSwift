//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Combine
import Observer

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PublisherTests: XCTestCase {

    class TestPublisher<Output, Failure: Error> : Publisher {

        init(values: [Result<Output, Failure>]) {

            self.values = values
        }

        convenience init(values: [Output]) {

            self.init(values: values.map { value in Result<Output, Failure>.success(value) })
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {

            subscribers.append { result in

                switch result {

                case .success(let value):
                    _ = subscriber.receive(value)

                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }

        func publishAll() {

            values.forEach { result in

                subscribers.forEach { subscriber in

                    subscriber(result)
                }
            }

            values.removeAll()
        }

        private var values: [Result<Output, Failure>]
        private var subscribers: [(Result<Output, Failure>) -> Void] = []
    }

    struct TestError: Error, Equatable {

        let message: String
    }

    func testPublisherToEventStream() throws {

        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let publisher = TestPublisher<Int, Never>(values: testValues)

        let stream: EventStream<Int> = publisher
            .toEventStream()

        var receivedValues: [Int] = []

        let subscription = stream.subscribe { value in

            receivedValues.append(value)
        }
        
        publisher.publishAll()

        XCTAssertEqual(receivedValues, testValues)

        withExtendedLifetime(subscription) { }
    }

    func testPublisherToEventStreamWithErrors() throws {

        var testValues = (0..<9).map { _ -> Result<Int, TestError> in

            .success(Int.random(in: 0..<1000))
        }

        testValues.append(.failure(TestError(message: "Some Error Message")))

        let publisher = TestPublisher(values: testValues)

        let stream = publisher
            .toEventStream()

        var receivedValues: [Result<Int, TestError>] = []

        let subscription = stream.subscribe { value in

            receivedValues.append(value)
        }

        publisher.publishAll()

        XCTAssertEqual(receivedValues, testValues)

        withExtendedLifetime(subscription) { }
    }

    func testEventStreamToEventPublisher() throws {

        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let source = SimpleChannel<Int>()
        let stream = source.asStream()

        let publisher: AnyPublisher<Event<Int>, Never> = stream
            .toPublisher()

        var receivedEvents: [Event<Int>] = []

        let subscription = publisher.sink { event in

            receivedEvents.append(event)
        }

        let startDate = Date()

        for testValue in testValues {
            source.publish(testValue)
        }

        let endDate = Date()

        let validDateRange = startDate..<endDate
        XCTAssertEqual(receivedEvents.map { event in event.value }, testValues)

        for receivedEvent in receivedEvents {
            XCTAssertTrue(validDateRange.contains(receivedEvent.time))
        }

        withExtendedLifetime(subscription) { }
    }

    func testEventStreamToValuePublisher() throws {

        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let source = SimpleChannel<Int>()
        let stream = source.asStream()

        let publisher: AnyPublisher<Int, Never> = stream
            .toPublisher()

        var receivedValues: [Int] = []

        let subscription = publisher.sink { value in

            receivedValues.append(value)
        }

        for testValue in testValues {
            source.publish(testValue)
        }

        XCTAssertEqual(receivedValues, testValues)

        withExtendedLifetime(subscription) { }
    }
}
