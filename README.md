# CryptoTracker

A modern, hybrid iOS application built with Swift that tracks real-time cryptocurrency data. This project demonstrates a production-level integration of UIKit and SwiftUI, utilizing modern Swift features like async/await, Swift Charts, and MVVM architecture.

## Features

- Hybrid Architecture using UIKit + SwiftUI via UIHostingConfiguration
- Paginated fetching of top cryptocurrencies using CoinRanking API
- Interactive historical price charts (24h, 7d, 30d)
- Advanced UI/UX including glassmorphism, dynamic theming, rank bubbles
- Search with instant client-side filtering
- Favorites watchlist with persistence
- Robust error handling with retry logic

## Tech Stack

- Swift 5
- UIKit, SwiftUI, Combine, Charts
- Async/Await concurrency
- iOS 16 minimum target
- No third‑party dependencies

## How to Build and Run

### 1. Clone the Repository
```bash
git clone https://github.com/VictorVilo/CryptoTracker.git
cd CryptoTracker
```

### 2. Configure the API Key

The API key is not included in the repo.

### Option A — Using `.xcconfig` (Recommended)

1. In Xcode, go to **File > New > File…**
2. Select **Configuration Settings File**
3. Name it `Secrets.xcconfig`
4. Save it in the project root
5. Add this line:

```
COINRANKING_API_KEY = your_coinranking_api_key_here
```

### Option B — User‑Defined Build Setting

1. Open Xcode  
2. Select the **CryptoTracker** target  
3. Go to **Build Settings**  
4. Click + → **Add User‑Defined Setting**  
5. Name it `COINRANKING_API_KEY`  
6. Add your API key  

### 3. Run the App
1. Select a simulator (e.g., iPhone 15 Pro)  
2. Press **Cmd + R**  

## Architecture & Decisions

### Hybrid UIKit + SwiftUI Approach
UIKit provides structural navigation and lifecycle control. SwiftUI handles dynamic visuals, cells, and charts.

### MVVM Pattern
- **Services** → Raw networking and decoding  
- **ViewModels** → Business logic, pagination, state  
- **Views** → Pure UI  

### Security
API keys are never hardcoded. They are injected through Build Settings and Info.plist variable substitution.

## Challenges & Solutions

### 1. Synchronizing Hybrid State
SwiftUI cells update instantly via `ObservableObject` and a shared `FavoritesManager`.

### 2. SVG Image Support
API provides SVG icons → converted requests to PNG to avoid dependencies.

### 3. Dynamic Theme Switching
Unified theme manager applies window.overrideUserInterfaceStyle with cross‑dissolve animation.

