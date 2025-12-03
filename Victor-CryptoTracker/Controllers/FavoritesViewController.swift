//
//  FavoritesViewController.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import UIKit
import SwiftUI
import Combine

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private var favoriteCoins: [Coin] = []
    private var cancellables = Set<AnyCancellable>()
    private var isLoading = false
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "FavCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.alwaysBounceVertical = true
        return tv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No Favorites Yet\nSwipe left on coins to add them here."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func loadFavorites() {
        let favIDs = FavoritesManager.shared.favoriteIDs
        
        if favIDs.isEmpty {
            self.favoriteCoins = []
            self.tableView.reloadData()
            self.updateEmptyState()
            return
        }
        
        loadingIndicator.startAnimating()
        emptyStateLabel.isHidden = true
        
        Task {
            do {
              
                let allCoins = try await CoinService.shared.fetchCoins(page: 1, limit: 100)
                
                self.favoriteCoins = allCoins.filter { favIDs.contains($0.uuid) }
                
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.tableView.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    print("Error loading favorites: \(error)")
                    self.updateEmptyState()
                }
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = favoriteCoins.isEmpty
        UIView.animate(withDuration: 0.3) {
            self.emptyStateLabel.isHidden = !isEmpty
            self.tableView.alpha = isEmpty ? 0 : 1
        }
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavCell", for: indexPath)
        let coin = favoriteCoins[indexPath.row]
        
        cell.contentConfiguration = UIHostingConfiguration {
            CoinRowView(coin: coin)
        }
        .margins(.vertical, 8)
        .margins(.horizontal, 16)
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = favoriteCoins[indexPath.row]
        let detailView = CoinDetailView(coin: coin)
        let hostVC = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(hostVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = favoriteCoins[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completion in
            guard let self = self else { return }
            
            FavoritesManager.shared.toggle(coin.uuid)
            self.favoriteCoins.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if self.favoriteCoins.isEmpty {
                self.updateEmptyState()
            }
            
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
