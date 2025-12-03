//
//  CoinDetailView.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import SwiftUI
import Charts

struct CoinDetailView: View {
    @StateObject private var viewModel: CoinDetailViewModel
    @ObservedObject var favorites = FavoritesManager.shared
    
    init(coin: Coin) {
        _viewModel = StateObject(wrappedValue: CoinDetailViewModel(coin: coin))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color(uiColor: .systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    VStack(spacing: 10) {
                        CoinImageView(url: viewModel.coin.pngIconUrl)
                            .frame(width: 90, height: 90)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text(viewModel.coin.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        
                        Text(viewModel.coin.symbol)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 5) {
                        Text(viewModel.coin.currentPrice.toCurrency())
                            .font(.system(size: 42, weight: .heavy, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.coin.performance >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text(viewModel.coin.performance.toPercentString())
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(viewModel.coin.performance >= 0 ? .green : .red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(viewModel.coin.performance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        )
                    }
                    
                    HStack(spacing: 15) {
                        RankBubbleView(rank: viewModel.coin.rank)
                        
                        MarketCapCardView(marketCap: viewModel.coin.marketCap)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Performance Trend")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Picker("Time", selection: $viewModel.selectedPeriod) {
                                Text("24H").tag("24h")
                                Text("7D").tag("7d")
                                Text("30D").tag("30d")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                            .onChange(of: viewModel.selectedPeriod) { _ in
                                viewModel.loadHistory()
                            }
                        }
                        .padding(.bottom, 10)
                        
                        if viewModel.isLoading {
                            VStack {
                                ProgressView()
                                Text("Fetching data...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 8)
                            }
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                        } else if !viewModel.history.isEmpty {
                            ChartView(history: viewModel.history, isPositive: viewModel.coin.performance >= 0)
                        } else {
                            ContentUnavailableView("No Data", systemImage: "chart.xyaxis.line")
                                .frame(height: 250)
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 50)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    favorites.toggle(viewModel.coin.uuid)
                } label: {
                    Image(systemName: favorites.isFavorite(viewModel.coin.uuid) ? "heart.fill" : "heart")
                        .foregroundStyle(favorites.isFavorite(viewModel.coin.uuid) ? .red : .primary)
                        .symbolEffect(.bounce, value: favorites.isFavorite(viewModel.coin.uuid))
                }
            }
        }
    }
}


struct RankBubbleView: View {
    let rank: Int
    
    var body: some View {
        VStack {
            Text("Rank")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 2)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                
                VStack(spacing: 0) {
                    Image(systemName: "crown.fill")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("#\(rank)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 80, height: 80)
        }
    }
}

struct MarketCapCardView: View {
    let marketCap: String?
    
    var formattedCap: String {
        return Double(marketCap ?? "0")?.toCurrency() ?? "N/A"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.blue)
                Text("Market Cap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(formattedCap)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .minimumScaleFactor(0.8)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(Double.random(in: 0.1...0.3)))
                        .frame(width: 4, height: Double.random(in: 10...30))
                }
            }
        }
        .padding()
        .frame(height: 100)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ChartView: View {
    let history: [HistoryPoint]
    let isPositive: Bool
    var body: some View {
        Chart {
            ForEach(history) { point in
                LineMark(x: .value("Date", point.date), y: .value("Price", point.doublePrice))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(isPositive ? .green : .red)
                AreaMark(x: .value("Date", point.date), y: .value("Price", point.doublePrice))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(colors: [(isPositive ? Color.green : Color.red).opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
            }
        }
        .chartYScale(domain: .automatic)
        .frame(height: 250)
    }
}
