//
//  APIConstants.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://api.coinranking.com/v2"

    static var apiKey: String {
        if let envKey = ProcessInfo.processInfo.environment["COINRANKING_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "CoinRankingAPIKey") as? String, !plistKey.isEmpty {
            return plistKey
        }
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
           let secret = plist["COINRANKING_API_KEY"] as? String, !secret.isEmpty {
            return secret
        }
        return ""
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .serverError(let msg): return msg
        default: return "An unexpected error occurred."
        }
    }
}

