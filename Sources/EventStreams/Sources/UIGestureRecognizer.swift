//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit

class UIGestureRecognizerEventStream {
    
    private class TargetBridge<Recognizer: UIGestureRecognizer>
    {
        init(
            publish: @escaping (Recognizer) -> Void
        ) {
            
            self.publish = publish
        }
        
        @objc func receive(sender: UIGestureRecognizer) {
            
            publish(sender as! Recognizer)
        }
        
        private let publish: (Recognizer) -> Void
    }

    static func eventStream<Recognizer: UIGestureRecognizer>(
        recognizer: Recognizer
    ) -> EventStream<Recognizer> {
        
        EventStream(
            registerValues: { publish, complete -> TargetBridge<Recognizer> in

                let bridge = TargetBridge(publish: publish)
                recognizer.addTarget(bridge, action: #selector(TargetBridge.receive))
                return bridge
            },
            unregister: { bridge in

                recognizer.removeTarget(bridge, action: #selector(TargetBridge.receive))
            }
        )
    }
}

extension UITapGestureRecognizer {

    func eventStream() -> EventStream<UITapGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}

#if !os(tvOS)
extension UIPinchGestureRecognizer {

    func eventStream() -> EventStream<UIPinchGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}

extension UIRotationGestureRecognizer {

    func eventStream() -> EventStream<UIRotationGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}
#endif

extension UISwipeGestureRecognizer {

    func eventStream() -> EventStream<UISwipeGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}

extension UIPanGestureRecognizer {

    func eventStream() -> EventStream<UIPanGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}

extension UILongPressGestureRecognizer {

    func eventStream() -> EventStream<UILongPressGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}

#if !os(tvOS)
@available(iOS 13.0, *)
extension UIHoverGestureRecognizer {

    func eventStream() -> EventStream<UIHoverGestureRecognizer> {

        UIGestureRecognizerEventStream.eventStream(recognizer: self)
    }
}
#endif

#endif
