////
////  CryptoRankerTests.swift
////  Victor-CryptoTracker
////
////  Created by Victor on 02/12/2025.
////
//
//import XCTest
//@testable import CryptoRanker
//
//class MockCoinService: CoinServiceProtocol {
//    var shouldFail = false
//    
//    func fetchCoins(page: Int, limit: Int) async throws -> [Coin] {
//        if shouldFail { throw APIError.serverError("Mock Fail") }
//        
//        // Return dummy data
//        return [
//            Coin(uuid: "1", symbol: "BTC", name: "Bitcoin", iconUrl: "", price: "50000", marketCap: nil, change: "5.0", rank: 1, sparkline: nil, description: nil, websiteUrl: nil),
//            Coin(uuid: "2", symbol: "ETH", name: "Ethereum", iconUrl: "", price: "3000", marketCap: nil, change: "-2.0", rank: 2, sparkline: nil, description: nil, websiteUrl: nil)
//        ]
//    }
//    
//    func fetchCoin(uuid: String) async throws -> Coin {
//        throw APIError.unknown(NSError(domain: "", code: 0))
//    }
//}
//
//@MainActor
//final class CoinViewModelTests: XCTestCase {
//
//    var viewModel: CoinListViewModel!
//    var mockService: MockCoinService!
//
//    override func setUp() {
//        mockService = MockCoinService()
//        viewModel = CoinListViewModel(service: mockService)
//    }
//
//    func testFetchCoinsSuccess() {
//        let expectation = XCTestExpectation(description: "Fetch Coins")
//        
//        // Observe ViewState
//        let cancellable = viewModel.$viewState
//            .dropFirst() // Drop initial idle
//            .sink { state in
//                if case .idle = state {
//                    expectation.fulfill()
//                }
//            }
//        
//        viewModel.fetchCoins(reset: true)
//        
//        wait(for: [expectation], timeout: 1.0)
//        XCTAssertEqual(viewModel.coins.count, 2)
//        XCTAssertEqual(viewModel.coins.first?.symbol, "BTC")
//    }
//    
//    func testFilterLogic() {
//        // Setup data synchronously for test
//        // In a real test, you'd access the underlying array directly or mock the async call completion
//        viewModel.fetchCoins(reset: true)
//        
//        let waitExp = XCTWaiter().wait(for: [XCTestExpectation(description: "Wait")], timeout: 0.5)
//        
//        viewModel.sort(by: .priceDesc)
//        XCTAssertEqual(viewModel.coins.first?.symbol, "BTC") // 50000 > 3000
//        
//        viewModel.sort(by: .performanceDesc)
//        XCTAssertEqual(viewModel.coins.first?.symbol, "BTC") // 5.0 > -2.0
//    }
//}
