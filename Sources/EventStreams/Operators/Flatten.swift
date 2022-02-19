//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream {

    public func flatten<InnerValue>() -> EventStream<InnerValue> where Value == EventStream<InnerValue> {

        EventStream<InnerValue>(
            registerEvents: { publish, complete in

                FlattenEventSource<InnerValue>(
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

class FlattenEventSource<Value>
{
    init(
        source: EventStream<EventStream<Value>>,
        publish: @escaping (Event<Value>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.source = source
        self.complete = complete
        
        var outerSubscription: Subscription!
        
        outerSubscription = source.subscribe(
            onValue: { innerStream in
                                
                var subscription: Subscription!
                
                subscription = innerStream
                    .subscribe(onEvent: publish, onComplete: {
                        
                        self.subscriptions.remove(subscription)
                        self.checkComplete()
                    })
                
                subscription
                    .store(in: &self.subscriptions)
                
            },
            onComplete: {
                
                self.subscriptions.remove(outerSubscription)
                self.checkComplete()
            }
        )
            
        outerSubscription
            .store(in: &subscriptions)
    }
    
    private func checkComplete() {
        
        if subscriptions.isEmpty {
            complete()
        }
    }
    
    let source: EventStream<EventStream<Value>>
    let complete: () -> Void
    
    var subscriptions = Set<Subscription>()
}