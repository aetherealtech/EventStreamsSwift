//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension EventStream where Value : EventStreamProtocol {

    public func flatten() -> EventStream<Value.Value> {

        EventStream<Value.Value>(
            registerEvents: { publish, complete in

                FlattenEventSource<Value>(
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

class FlattenEventSource<SourceStream: EventStreamProtocol>
{
    typealias Value = SourceStream.Value
    
    init(
        source: EventStream<SourceStream>,
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
    
    let source: EventStream<SourceStream>
    let complete: () -> Void
    
    var subscriptions = Set<Subscription>()
}