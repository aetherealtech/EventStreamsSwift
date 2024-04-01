//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit
import Observer
import Scheduling

public protocol UIControlProtocol: UIControl {}

extension UIControl: UIControlProtocol {}

public extension UIControlProtocol {
    func stream(
        for event: Event
    ) -> UIControlEventStream<Self> {
        .init(
            control: self,
            event: event
        )
    }
}

public struct UIControlEventStream<
    Control: UIControl
>: EventStream {
    public final class Subscription: Observer.Subscription {
        init(
            source: Control,
            event: UIControl.Event,
            handler: @escaping @Sendable (UIEvent) -> Void
        ) {
            self.source = source
            self.event = event
            self.handler = handler

            DispatchQueue.main.async {
                source.addTarget(self, action: #selector(self.receive), for: event)
            }
        }

        public func cancel() {
            DispatchQueue.main.async {
                self.source.removeTarget(self, action: #selector(self.receive), for: self.event)
            }
        }

        @objc private func receive(sender: UIControl, event: UIEvent) {
            handler(event)
        }

        private let source: Control
        private let event: UIControl.Event
        private let handler: @Sendable (UIEvent) -> Void
    }
    
    public func subscribe(
        _ onValue: @escaping @Sendable (UIEvent) -> Void
    ) -> Subscription {
        .init(
            source: control,
            event: event,
            handler: onValue
        )
    }

    init(
        control: Control,
        event: UIControl.Event
    ) {
        self.control = control
        self.event = event
    }

    public let control: Control
    public let event: UIControl.Event
}

#endif
