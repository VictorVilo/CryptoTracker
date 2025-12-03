//
//  AppEntry.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import SwiftUI
import UIKit

struct MainNavigationWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let homeVC = HomeViewController()
        
        let nav = UINavigationController(rootViewController: homeVC)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance
        
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
