//
//  TimeTracker.swift
//  test
//
//  Created by Vadim on 12/28/21.
//

import Foundation

class TimeTracker {
    var markedDate = Date()
    func mark() {
        markedDate = Date()
    }

    func reportElapsed(prefix: String = "Elapsed: ") -> String {
        return prefix + "\(Date().timeIntervalSince(markedDate).round(to: 2))"
    }
}
