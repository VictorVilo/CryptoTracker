//
//  Components.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 03/12/2025.
//

import SwiftUI

struct CoinImageView: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .foregroundStyle(.gray)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct HomeHeaderView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good Morning 🌅"
        case 12..<17: return "Good Afternoon ☀️"
        case 17..<21: return "Good Evening 🌆"
        default: return "Hello Night Owl 🌙"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(greeting)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text("CryptoTracker")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isDarkMode.toggle()
                    updateTheme()
                }
            }) {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(isDarkMode ? .yellow : .orange)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 10)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear { updateTheme() }
    }
    
    private func updateTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.overrideUserInterfaceStyle = self.isDarkMode ? .dark : .light
        }, completion: nil)
    }
}

struct ModernStatBox: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.headline)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
