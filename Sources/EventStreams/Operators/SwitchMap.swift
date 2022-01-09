//
//  File.swift
//  
//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

extension EventStream {

    public func switchMap<Result>(_ transform: @escaping (Payload) -> EventStream<Result>) -> EventStream<Result> {

        self
            .map(transform)
            .switch()
    }
}
