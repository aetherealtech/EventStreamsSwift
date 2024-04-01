//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit
import Observer

public protocol UIGestureRecognizerProtocol: UIGestureRecognizer {}

extension UIGestureRecognizer: UIGestureRecognizerProtocol {}

public extension UIGestureRecognizerProtocol {
    var stream: UIGestureRecognizerEventStream<Self> {
        .init(gestureRecoginizer: self)
    }
}

public struct UIGestureRecognizerEventStream<
    Recognizer: UIGestureRecognizer
> : EventStream {
    public final class Subscription: Observer.Subscription {
        init(
            recognizer: Recognizer,
            handler: @escaping @Sendable (Recognizer) -> Void
        ) {
            self.recognizer = recognizer
            self.handler = handler

            DispatchQueue.main.async {
                recognizer.addTarget(self, action: #selector(self.receive))
            }
        }

        public func cancel() {
            DispatchQueue.main.async {
                self.recognizer.removeTarget(self, action: #selector(self.receive))
            }
        }
        
        @objc private func receive(sender: UIGestureRecognizer) {
            handler(sender as! Recognizer)
        }

        private let recognizer: Recognizer
        private let handler: @Sendable (Recognizer) -> Void
    }

    public func subscribe(
        _ onValue: @escaping @Sendable (Recognizer) -> Void
    ) -> Subscription {
        .init(
            recognizer: gestureRecoginizer,
            handler: onValue
        )
    }
    
    init(
        gestureRecoginizer: Recognizer
    ) {
        self.gestureRecoginizer = gestureRecoginizer
    }

    public let gestureRecoginizer: Recognizer
}

#endif
