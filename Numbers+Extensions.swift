//
//  Numbers+Extensions.swift
//  test
//
//  Created by Vadim on 12/28/21.
//

import Foundation
import UIKit

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CGFloat {
    func round(to places: Int) -> CGFloat {
        CGFloat(Double(self).round(to: places))
    }
}

extension Float {
    func round(to places: Int) -> Float {
        Float(Double(self).round(to: places))
    }
}
