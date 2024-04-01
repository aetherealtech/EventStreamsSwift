//
//  Created by Daniel Coleman on 11/18/21.
//

import Assertions
import XCTest
import Combine
import Observer
import Synchronization

@testable import EventStreams

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class PublisherTests: XCTestCase {
//    final class TestPublisher<Output, Failure: Error> : Publisher {
//        init(values: [Result<Output, Failure>]) {
//            self.values = values
//        }
//
//        convenience init(values: [Output]) {
//            self.init(values: values.map { value in Result<Output, Failure>.success(value) })
//        }
//
//        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
//            subscribers.append { result in
//                switch result {
//                    case .success(let value): _ = subscriber.receive(value)
//                    case .failure(let error): subscriber.receive(completion: .failure(error))
//                }
//            }
//        }
//
//        func publishAll() {
//            values.forEach { result in
//                subscribers.forEach { subscriber in
//                    subscriber(result)
//                }
//            }
//
//            values.removeAll()
//        }
//        
//        private final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
//            init(subscriber: S) {
//                self.subscriber = subscriber
//            }
//            
//            func request(_ demand: Subscribers.Demand) {
//                <#code#>
//            }
//            
//            func cancel() {
//                <#code#>
//            }
//            
//            private let subscriber: S
//            private var demand = Subscribers.Demand.none
//        }
//
//        private var values: [Result<Output, Failure>]
//        private var subscribers: [(Result<Output, Failure>) -> Void] = []
//    }

    struct TestError: Error, Equatable {
        let message: String
    }

    func testPublisherToEventStream() throws {
        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let publisher = PassthroughSubject<Int, Never>()

        let stream = publisher.publish().stream
        
        @Synchronized
        var receivedValues: [Int] = []

        let _ = stream.subscribe { [_receivedValues] value in
            _receivedValues.wrappedValue.append(value)
        }
        
        for value in testValues {
            publisher.send(value)
        }

        try assertEqual(receivedValues, testValues)
    }

    func testPublisherToEventStreamWithErrors() throws {
        var testValues = (0..<9).map { _ in
            Int.random(in: 0..<1000)
        }

        let testError = TestError(message: "Some Error Message")

        let expectedValues = testValues
            .map(Result<Int, TestError>.success)
            .appending(Result<Int, TestError>.failure(testError))
        
        let publisher = PassthroughSubject<Int, TestError>()

        let stream = publisher.publish().stream
        
        @Synchronized
        var receivedValues: [Result<Int, TestError>] = []

        let _ = stream.subscribe { [_receivedValues] value in
            _receivedValues.wrappedValue.append(value)
        }
        
        for value in testValues {
            publisher.send(value)
        }

        publisher.send(completion: .failure(testError))

        try assertEqual(receivedValues, expectedValues)
    }

    func testEventStreamToEventPublisher() throws {
        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let source = SimpleChannel<Int>()
        let stream = source.stream

        let publisher = stream
            .publisher

        var receivedValues: [Int] = []

        let subscription = publisher
            .sink { event in
                receivedValues.append(event)
            }

        for testValue in testValues {
            source.publish(testValue)
        }

        try assertEqual(receivedValues, testValues)
        
        withExtendedLifetime(subscription) {}
    }

    func testEventStreamToValuePublisher() throws {
        let testValues = (0..<10).map { _ in Int.random(in: 0..<1000) }

        let source = SimpleChannel<Int>()
        let stream = source.stream

        let publisher = stream
            .publisher

        var receivedValues: [Int] = []

        let subscription = publisher.sink { value in
            receivedValues.append(value)
        }

        for testValue in testValues {
            source.publish(testValue)
        }

        try assertEqual(receivedValues, testValues)
        
        withExtendedLifetime(subscription) {}
    }
}
