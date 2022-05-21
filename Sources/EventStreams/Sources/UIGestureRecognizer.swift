//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit
import Observer

extension UIGestureRecognizer {

    private class GestureRecognizerSubscription<Recognizer: UIGestureRecognizer> : Subscription {

        private class TargetBridge
        {
            init(
                handler: @escaping (Recognizer) -> Void
            ) {

                self.handler = handler
            }

            @objc func receive(sender: UIGestureRecognizer) {

                handler(sender as! Recognizer)
            }

            private let handler: (Recognizer) -> Void
        }

        init(
            recognizer: Recognizer,
            handler: @escaping (Recognizer) -> Void
        ) {
            self.recognizer = recognizer
            self.bridge = TargetBridge(handler: handler)

            recognizer.addTarget(bridge, action: #selector(TargetBridge.receive))
        }

        deinit {

            recognizer.removeTarget(bridge, action: #selector(TargetBridge.receive))
        }

        private let recognizer: Recognizer
        private let bridge: TargetBridge
    }

    static func addTarget<Recognizer: UIGestureRecognizer>(
        recognizer: Recognizer,
        handler: @escaping (Recognizer) -> Void
    ) -> Subscription {

        GestureRecognizerSubscription(
            recognizer: recognizer,
            handler: handler
        )
    }

    static func eventStream<Recognizer: UIGestureRecognizer>(
        recognizer: Recognizer
    ) -> EventStream<Recognizer> {
        
        UIGestureRecognizerEventStream(source: recognizer)
    }
}

class UIGestureRecognizerEventStream<Recognizer: UIGestureRecognizer> : EventStream<Recognizer> {

    init(
        source: Recognizer
    ) {

        self.source = source

        let eventChannel = SimpleChannel<Event<Recognizer>>()
        let completeChannel = SimpleChannel<Void>()

        subscription = UIGestureRecognizer.addTarget(
            recognizer: source,
            handler: { event in eventChannel.publish(Event(event)) }
        )

        super.init(
            eventChannel: eventChannel,
            completeChannel: completeChannel
        )
    }

    private let source: Recognizer

    private let subscription: Subscription
}

extension UITapGestureRecognizer {

    func eventStream() -> EventStream<UITapGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}

#if !os(tvOS)
extension UIPinchGestureRecognizer {

    func eventStream() -> EventStream<UIPinchGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}

extension UIRotationGestureRecognizer {

    func eventStream() -> EventStream<UIRotationGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}
#endif

extension UISwipeGestureRecognizer {

    func eventStream() -> EventStream<UISwipeGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}

extension UIPanGestureRecognizer {

    func eventStream() -> EventStream<UIPanGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}

extension UILongPressGestureRecognizer {

    func eventStream() -> EventStream<UILongPressGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}

#if !os(tvOS)
@available(iOS 13.0, *)
extension UIHoverGestureRecognizer {

    func eventStream() -> EventStream<UIHoverGestureRecognizer> {

        UITapGestureRecognizer.eventStream(recognizer: self)
    }
}
#endif

#endif
