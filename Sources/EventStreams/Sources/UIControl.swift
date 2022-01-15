//
//  Created by Daniel Coleman on 1/9/22.
//

#if !os(macOS) && !os(watchOS)

import UIKit
import Observer
import Scheduling

extension UIControl {

    private class TargetBridge : NSObject
    {
        init(
            publish: @escaping (UIEvent) -> Void
        ) {
            
            self.publish = publish
        }

        @objc func receive(sender: UIControl, event: UIEvent) {
            
            publish(event)
        }
        
        private let publish: (UIEvent) -> Void
    }

    func eventStream(for event: Event) -> EventStream<UIEvent> {

        EventStream(
            registerValues: { publish, complete -> TargetBridge in

                let bridge = TargetBridge(publish: publish)
                self.addTarget(bridge, action: #selector(TargetBridge.receive), for: event)
                return bridge
            },
            unregister: { bridge in

                self.removeTarget(bridge, action: #selector(TargetBridge.receive), for: event)
            }
        )
    }
}

#endif
