//
//  CoinRowView.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import SwiftUI

struct CoinRowView: View {
    let coin: Coin
    @ObservedObject var favorites = FavoritesManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            CoinImageView(url: coin.pngIconUrl)
                .frame(width: 45, height: 45)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(coin.symbol)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.currentPrice.toCurrency())
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 2) {
                    Image(systemName: coin.performance >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(coin.performance.toPercentString())
                }
                .font(.caption)
                .foregroundStyle(coin.performance >= 0 ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(coin.performance >= 0 ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                )
            }
            
            if favorites.isFavorite(coin.uuid) {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.title3)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(
            color: colorScheme == .dark ? .clear : .black.opacity(0.08),
            radius: 10, x: 0, y: 5
        )
    }
}
