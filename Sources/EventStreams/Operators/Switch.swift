 //
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream where Value : EventStreamProtocol {

    public func `switch`() -> EventStream<Value.Value> {

        EventStream<Value.Value>(
            registerEvents: { publish, complete in

                SwitchEventSource<Value>(
                    source: self,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

class SwitchEventSource<SourceStream: EventStreamProtocol>
{
    typealias Value = SourceStream.Value
    
    init(
        source: EventStream<SourceStream>,
        publish: @escaping (Event<Value>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        self.complete = complete
                
        outerSubscription = source.subscribe(
            onValue: { innerStream in
                                                
                self.innerSubscription = innerStream
                    .subscribe(onEvent: publish, onComplete: {
                        
                        self.innerSubscription = nil
                        self.checkComplete()
                    })
                
            },
            onComplete: {
                
                self.outerSubscription = nil
                self.checkComplete()
            }
        )
    }
    
    private func checkComplete() {
        
        if outerSubscription == nil && innerSubscription == nil {
            complete()
        }
    }
    
    let source: EventStream<SourceStream>
    let complete: () -> Void
    
    var outerSubscription: Subscription! = nil
    var innerSubscription: Subscription! = nil
}
