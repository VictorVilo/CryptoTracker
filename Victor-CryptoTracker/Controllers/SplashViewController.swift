//
//  SplashViewController.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 03/12/2025.
//

import UIKit

class SplashViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bitcoinsign.circle.fill"))
        iv.tintColor = .systemBlue
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.alpha = 0
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.transitionToHome() }
        }
    }
    
    private func transitionToHome() {
        guard let windowScene = view.window?.windowScene,
              let delegate = windowScene.delegate as? SceneDelegate,
              let window = delegate.window else { return }
        
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = nav
        }, completion: nil)
    }
}
