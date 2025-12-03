//
//  CoinService.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import Foundation

protocol CoinServiceProtocol {
    func fetchCoins(page: Int, limit: Int) async throws -> [Coin]
    func fetchCoinHistory(uuid: String, period: String) async throws -> [HistoryPoint]
}

class CoinService: CoinServiceProtocol {
    static let shared = CoinService()
    
    func fetchCoins(page: Int, limit: Int = 20) async throws -> [Coin] {
        let offset = (page - 1) * limit
        let urlString = "\(APIConstants.baseURL)/coins?limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        let data: CoinResponse = try await performRequest(url: url)
        return data.data.coins
    }
    
    func fetchCoinHistory(uuid: String, period: String) async throws -> [HistoryPoint] {
        let urlString = "\(APIConstants.baseURL)/coin/\(uuid)/history?timePeriod=\(period)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        
        let data: CoinHistoryResponse = try await performRequest(url: url)
        return data.data.history
    }
    
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if !APIConstants.apiKey.isEmpty {
            request.addValue(APIConstants.apiKey, forHTTPHeaderField: "x-access-token")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw APIError.serverError("Server Error")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
}
