//
//  RateLimiter.swift
//  SwiftAPIClient
//
//  Created by James Mark on 12/14/25.
//

import Foundation

public actor RateLimiter {
    private var lastRequestTime: Date?

    public init() {}

    public func waitIfNeeded(minInterval: TimeInterval) async {
        let now = Date()
        if let last = lastRequestTime {
            let delta = now.timeIntervalSince(last)
            if delta < minInterval {
                try? await Task.sleep(
                    nanoseconds: UInt64((minInterval - delta) * 1_000_000_000)
                )
            }
        }
        lastRequestTime = Date()
    }
}
