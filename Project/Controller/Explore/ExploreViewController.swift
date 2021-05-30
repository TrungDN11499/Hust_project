//
//  ExploreViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit
import Firebase

private let cellIden = "UserCell"

class ExploreViewController: UITableViewController {

    // MARK: - Properties
    
    private var users = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var filterUsers = [User]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var inSearchMode: Bool {
        return self.searchController.isActive && !self.searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - API
    
    private func fetchUser() {
        UserService.shared.fetchUser { [weak self] (users) in
            guard let `self` = self else { return }
            self.users = users.filter { !$0.isCurrentUser }
        }
    }
    
    // MARK: - Helpers
    private func configureViewController() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "Explore"
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellIden)
        self.tableView.rowHeight = 60
//        tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        
        self.configureSearchController()
    }
    
    private func configureSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Who are you looking for"
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = true
        self.searchController.searchBar.barTintColor = UIColor.clear
        self.searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.clear 
        
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.navigationBarColor.cgColor,UIColor.navigationBarColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)

            if let image = UIImage.getImageFrom(gradientLayer: gradient) {
                let app = UINavigationBarAppearance()
                app.backgroundImage = image
                self.navigationController?.navigationBar.scrollEdgeAppearance = app
                self.navigationController?.navigationBar.standardAppearance = app
            }
        }
        
        
        self.definesPresentationContext = false
    }
}

// MARK: - UITableViewDelegate

extension ExploreViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.inSearchMode ? self.filterUsers[indexPath.row] : self.users[indexPath.row]
        let profileController = ProfileController(user)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ExploreViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inSearchMode ? self.filterUsers.count : self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIden, for: indexPath) as? UserCell else {
            return UITableViewCell()
        }
        let user = self.inSearchMode ? self.filterUsers[indexPath.row] : self.users[indexPath.row]
        cell.user = user
        return cell
    }
}

// MARK: - UISearchResultsUpdating
extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        let filteredResults = self.users.filter { $0.fullName.replacingOccurrences(of: " ", with: "").lowercased().contains(searchText.replacingOccurrences(of: " ", with: "").lowercased())
        }
        self.filterUsers = filteredResults
    }
}
