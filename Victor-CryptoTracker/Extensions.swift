//
//  Extensions.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 03/12/2025.
//

import Foundation
import SwiftUI

extension Double {
    func toCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    func toPercentString() -> String {
        return String(format: "%.2f%%", self)
    }
}

extension String {
    var removingHTMLOccurances: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
