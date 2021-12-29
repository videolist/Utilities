//
//  MemorySnapshot.swift
//  test
//
//  Created by Vadim on 12/28/21.
//

import Foundation

class MemorySnapshot {
    var lastSnapshot: task_vm_info_data_t?

    func reportIncrease(_ prefix: String = "") -> String {
        guard let info = takeSnapshot() else {
            return "N/A"
        }

        var string = prefix + "Total: \(info.usedMB)"
        if let lastSnapshot = lastSnapshot {
            string += " Increase: \(lastSnapshot.delta(with: info))"
        }
        lastSnapshot = info
        return string
    }

    func mark(_ prefix: String = "") -> String {
        guard let info = takeSnapshot() else {
            return "N/A"
        }
        lastSnapshot = info
        return prefix + "Total: \(info.usedMB)"
    }

    private func takeSnapshot() -> task_vm_info_data_t? {
        // Borrowed from https://stackoverflow.com/questions/40991912/how-to-get-memory-usage-of-my-application-and-system-in-swift-by-programatically/40992791
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        guard let offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else { return nil }
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(offset / MemoryLayout<integer_t>.size)
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return nil }

        return info
    }
}

let meg: Double = 1024 * 1024
extension task_vm_info_data_t {
    var usedMB: Double {
        (Double(phys_footprint) / meg).round(to: 2)
    }

    func delta(with info: Self) -> Double {
        (info.usedMB - usedMB).round(to: 2)
    }
}
