//
//  GroupsViewController.swift
//  Triponus
//
//  Created by Be More on 26/05/2021.
//

import UIKit

class GroupsViewController: UIViewController {
    
    // MARK: -- Properties
    private var inSearchMode: Bool {
        return self.searchController.isActive && !self.searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: -- Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Groups"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView() {
        self.setUpSearchBar()
    }
}

// MARK: -- Helpers
extension GroupsViewController {
    private func setUpSearchBar() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search for group tweet"
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.searchBar.barTintColor = UIColor.clear
        self.searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.clear
        
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.primary.cgColor, UIColor.secondary.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)

            if let image = UIImage.getImageFrom(gradientLayer: gradient) {
                let app = UINavigationBarAppearance()
                app.backgroundImage = image
                self.navigationController?.navigationBar.scrollEdgeAppearance = app
                self.navigationController?.navigationBar.standardAppearance = app

            }
            navigationBar.applyNavBarCornerRadius(with: 44, radius: 12)
        }
        
        
        self.definesPresentationContext = false

    }
}

// MARK: - UISearchResultsUpdating
extension GroupsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        print(searchText)
    }
}
