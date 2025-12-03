//
//  CoinModels.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import Foundation

struct CoinResponse: Codable {
    let status: String
    let data: CoinData
}

struct CoinData: Codable {
    let coins: [Coin]
}

struct CoinHistoryResponse: Codable {
    let status: String
    let data: HistoryData
}

struct HistoryData: Codable {
    let change: String?
    let history: [HistoryPoint]
}

struct Coin: Codable, Identifiable, Hashable {
    let uuid: String
    let symbol: String
    let name: String
    let iconUrl: String
    let price: String
    let marketCap: String?
    let change: String?
    let rank: Int
    let sparkline: [String]?
    
    var id: String { uuid }
    
    var currentPrice: Double { Double(price) ?? 0.0 }
    var performance: Double { Double(change ?? "0") ?? 0.0 }
    
    var pngIconUrl: URL? {
        return URL(string: iconUrl.replacingOccurrences(of: ".svg", with: ".png"))
    }
}

struct HistoryPoint: Codable, Identifiable {
    let price: String
    let timestamp: Int
    
    var id: Int { timestamp }
    var doublePrice: Double { Double(price) ?? 0.0 }
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
}
