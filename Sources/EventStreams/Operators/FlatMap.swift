//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func flatMap<Result>(_ transform: @escaping (Payload) -> EventStream<Result>) -> EventStream<Result> {

        flatMap { payload, date in
            
            transform(payload)
        }
    }
    
    public func flatMap<Result>(_ transform: @escaping (Payload, Date) -> EventStream<Result>) -> EventStream<Result> {

        self
            .map(transform)
            .flatten()
    }
}
