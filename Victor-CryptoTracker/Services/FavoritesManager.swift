//
//  FavouritesManager.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 03/12/2025.
//

import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    private let key = "favorites_uuids"
    
    @Published var favoriteIDs: Set<String> = []
    
    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: key) ?? []
        favoriteIDs = Set(saved)
    }
    
    func toggle(_ uuid: String) {
        if favoriteIDs.contains(uuid) {
            favoriteIDs.remove(uuid)
        } else {
            favoriteIDs.insert(uuid)
        }
        save()
    }
    
    func isFavorite(_ uuid: String) -> Bool {
        return favoriteIDs.contains(uuid)
    }
    
    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: key)
    }
}
