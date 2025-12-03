//
//  HTTPClient.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import Foundation

protocol HTTPClientProtocol {
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

class HTTPClient: HTTPClientProtocol {
    static let shared = HTTPClient()
    
    private init() {}
    
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Server returned \(httpResponse.statusCode)")
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("Decoding Error: \(error)")
            throw APIError.decodingError
        }
    }
}
