//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit
import Observer
import Scheduling

extension UIControl {

    private class ControlSubscription : Subscription {

        private class TargetBridge : NSObject
        {
            init(
                handler: @escaping (UIEvent) -> Void
            ) {

                self.handler = handler
            }

            @objc func receive(sender: UIControl, event: UIEvent) {

                handler(event)
            }

            private let handler: (UIEvent) -> Void
        }

        init(
            source: UIControl,
            event: UIControl.Event,
            handler: @escaping (UIEvent) -> Void
        ) {
            self.source = source
            self.event = event
            self.bridge = TargetBridge(handler: handler)

            source.addTarget(bridge, action: #selector(TargetBridge.receive), for: event)
        }

        deinit {

            source.removeTarget(bridge, action: #selector(TargetBridge.receive), for: event)
        }

        private let source: UIControl
        private let event: UIControl.Event
        private let bridge: TargetBridge
    }

    func addTarget(event: Event, handler: @escaping (UIEvent) -> Void) -> Subscription {

        ControlSubscription(
            source: self,
            event: event,
            handler: handler
        )
    }

    func eventStream(for event: Event) -> EventStream<UIEvent> {

        UIControlEventStream(
            source: self,
            event: event
        )
    }
}

class UIControlEventStream : EventStream<UIEvent> {

    init(
        source: UIControl,
        event: UIControl.Event
    ) {

        self.source = source
        self.event = event

        let channel = SimpleChannel<UIEvent>()

        subscription = source.addTarget(
            event: event,
            handler: { event in channel.publish(event) }
        )

        super.init(
            channel: channel
        )
    }

    private let source: UIControl
    private let event: UIControl.Event

    private let subscription: Subscription
}

#endif
