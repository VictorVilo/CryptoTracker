//
//  CoinListViewModel.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import Foundation
import Combine

enum SortOption {
    case priceDesc
    case performanceDesc
    case none
}

@MainActor
class CoinListViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var viewState: ViewState = .idle
    
    enum ViewState {
        case idle, loading, error(String)
    }
    
    private var allCoins: [Coin] = []
    
    private var currentPage = 1
    private var canLoadMore = true
    private var isFetching = false
    
    private var currentSortOption: SortOption = .none
    private var currentSearchQuery: String = ""
    
    func fetchCoins(reset: Bool = false) {
        guard !isFetching && canLoadMore && currentSearchQuery.isEmpty else { return }
        
        if reset {
            currentPage = 1
            coins = []
            allCoins = []
            canLoadMore = true
            viewState = .loading
        }
        
        isFetching = true
        
        Task {
            do {
                let newCoins = try await CoinService.shared.fetchCoins(page: currentPage)
                if newCoins.isEmpty { canLoadMore = false }
                
                self.allCoins.append(contentsOf: newCoins)
                
                self.applyFilters()
                
                self.currentPage += 1
                self.viewState = .idle
                self.isFetching = false
            } catch {
                self.viewState = .error(error.localizedDescription)
                self.isFetching = false
            }
        }
    }
        
    func search(query: String) {
        self.currentSearchQuery = query
        applyFilters()
    }
    
    func sort(by option: SortOption) {
        self.currentSortOption = option
        applyFilters()
    }
    
    private func applyFilters() {
        var result = allCoins
        
        if !currentSearchQuery.isEmpty {
            result = result.filter { coin in
                return coin.name.localizedCaseInsensitiveContains(currentSearchQuery) ||
                       coin.symbol.localizedCaseInsensitiveContains(currentSearchQuery)
            }
        }
        
        switch currentSortOption {
        case .priceDesc:
            result.sort { $0.currentPrice > $1.currentPrice }
        case .performanceDesc:
            result.sort { $0.performance > $1.performance }
        case .none:
            break
        }
        
        self.coins = result
    }
}
