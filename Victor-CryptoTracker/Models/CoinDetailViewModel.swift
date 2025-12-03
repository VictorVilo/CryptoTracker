//
//  CoinDetailViewModel.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 03/12/2025.
//

import Foundation
import Combine

@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var history: [HistoryPoint] = []
    @Published var isLoading = false
    @Published var selectedPeriod = "24h"
    
    let coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
        loadHistory()
    }
    
    func loadHistory() {
        isLoading = true
        Task {
            do {
                let data = try await CoinService.shared.fetchCoinHistory(uuid: coin.uuid, period: selectedPeriod)
                self.history = data.sorted { $0.timestamp < $1.timestamp }
                self.isLoading = false
            } catch {
                print("History Error: \(error)")
                self.isLoading = false
            }
        }
    }
}
