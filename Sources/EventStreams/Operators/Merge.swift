//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation
import Observer

extension Collection {

    public func merge<Value>() -> EventStream<Value> where Element == EventStream<Value> {

        EventStream<Value>(
            registerEvents:  { publish, complete in

                MergeEventSource<Value, Self>(
                    sources: self,
                    publish: publish,
                    complete: complete
                )
            },
            unregister: { source in

            }
        )
    }
}

extension EventStream {

    public func merge(_ other: EventStream<Value>) -> EventStream<Value> {

        return [self, other].merge()
    }
}

class MergeEventSource<Value, SourceCollection: Collection> where SourceCollection.Element == EventStream<Value>
{
    init(
        sources: SourceCollection,
        publish: @escaping (Event<Value>) -> Void,
        complete: @escaping () -> Void
    ) {
        
        self.sources = sources
        self.complete = complete
        
        for source in sources {
            
            var subscription: Subscription!
            
            subscription = source.subscribe(
                onEvent: publish,
                onComplete: {
                    
                    self.subscriptions.remove(subscription)
                    self.checkComplete()
                }
            )
                
            subscription
                .store(in: &subscriptions)
        }
    }
    
    private func checkComplete() {
        
        if subscriptions.isEmpty {
            complete()
        }
    }
    
    let sources: SourceCollection
    let complete: () -> Void
    
    var subscriptions = Set<Subscription>()
}
