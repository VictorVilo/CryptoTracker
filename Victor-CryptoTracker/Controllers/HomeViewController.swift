//
//  HomeViewController.swift
//  Victor-CryptoTracker
//
//  Created by Victor on 02/12/2025.
//

import UIKit
import SwiftUI
import Combine

class HomeViewController: UIViewController {
    
    private let viewModel = CoinListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var currentSortOption: SortOption = .none
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "CoinCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.keyboardDismissMode = .onDrag
        return tv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        setupHeader()
        setupBindings()
        updateFilterMenu()
        viewModel.fetchCoins(reset: true)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Markets"
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(goToFavs))
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Coins (e.g. BTC)"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false // Keep it visible or true to hide
        
        definesPresentationContext = true
    }
    
    private func setupHeader() {
        let headerView = HomeHeaderView()
        let hostingController = UIHostingController(rootView: headerView)
        
        guard let headerUIView = hostingController.view else { return }
        headerUIView.backgroundColor = .clear
        
        let size = headerUIView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerUIView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        tableView.tableHeaderView = headerUIView
    }
        
    private func updateFilterMenu() {
        let priceAction = UIAction(
            title: "Highest Price",
            image: UIImage(systemName: "dollarsign.circle"),
            state: currentSortOption == .priceDesc ? .on : .off
        ) { [weak self] _ in
            self?.currentSortOption = .priceDesc
            self?.viewModel.sort(by: .priceDesc)
            self?.updateFilterMenu()
        }
        
        let perfAction = UIAction(
            title: "Best 24h Performance",
            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
            state: currentSortOption == .performanceDesc ? .on : .off
        ) { [weak self] _ in
            self?.currentSortOption = .performanceDesc
            self?.viewModel.sort(by: .performanceDesc)
            self?.updateFilterMenu()
        }
        
        let resetAction = UIAction(
            title: "Reset",
            image: UIImage(systemName: "arrow.counterclockwise"),
            attributes: .destructive,
            state: currentSortOption == .none ? .on : .off
        ) { [weak self] _ in
            self?.currentSortOption = .none
            self?.viewModel.sort(by: .none)
            self?.updateFilterMenu()
        }
        
        let menu = UIMenu(title: "Sort Options", children: [priceAction, perfAction, resetAction])
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), menu: menu)
    }
    
    private func setupBindings() {
        viewModel.$coins
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
            
        viewModel.$viewState
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .idle: self?.loadingIndicator.stopAnimating()
                case .loading: self?.loadingIndicator.startAnimating()
                case .error(let msg):
                    self?.loadingIndicator.stopAnimating()
                    self?.showError(msg)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
            self.viewModel.fetchCoins(reset: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func goToFavs() {
        let vc = FavoritesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.search(query: text)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath)
            
           
            guard indexPath.row < viewModel.coins.count else {
                return UITableViewCell()
            }
            
            let coin = viewModel.coins[indexPath.row]
            let isFav = FavoritesManager.shared.isFavorite(coin.uuid)
            
            cell.contentConfiguration = UIHostingConfiguration {
                CoinRowView(coin: coin)
            }
            .margins(.vertical, 8)
            .margins(.horizontal, 16)
            
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            
            if !searchController.isActive,
               indexPath.row == viewModel.coins.count - 1 {
                viewModel.fetchCoins()
            }
            
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = viewModel.coins[indexPath.row]
        let detail = CoinDetailView(coin: coin)
        let host = UIHostingController(rootView: detail)
        navigationController?.pushViewController(host, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.coins[indexPath.row]
        let isFav = FavoritesManager.shared.isFavorite(coin.uuid)
        
        let action = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            FavoritesManager.shared.toggle(coin.uuid)
            completion(true)
        }
        
        action.backgroundColor = isFav ? .systemRed : .systemBlue
        action.image = UIImage(systemName: isFav ? "heart.slash.fill" : "heart.fill")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
