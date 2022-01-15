//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func flatMap<Result>(_ transform: @escaping (Value) -> EventStream<Result>) -> EventStream<Result> {

        flatMap { value, date in
            
            transform(value)
        }
    }
    
    public func flatMap<Result>(_ transform: @escaping (Value, Date) -> EventStream<Result>) -> EventStream<Result> {

        self
            .map(transform)
            .flatten()
    }
}
