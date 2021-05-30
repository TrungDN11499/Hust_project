//
//  GroupsViewController.swift
//  Triponus
//
//  Created by Be More on 26/05/2021.
//

import UIKit

class GroupsViewController: UIViewController {
    
    // MARK: -- Properties
    @IBOutlet weak var tweetCollectionView: UICollectionView!
    
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
}

// MARK: -- Helpers
extension GroupsViewController {
    private func configureView() {
        self.setUpSearchBar()
    }
    
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
            gradient.colors = [UIColor.navigationBarColor.cgColor, UIColor.navigationBarColor.cgColor]
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

        let addButon = UIBarButtonItem(image: UIImage(named: "ic_add"), style: .plain, target: self, action: #selector(handleCreateGroup(_:)))
        self.navigationItem.rightBarButtonItem = addButon
        
    }
}

// MARK: -- Selectors
extension GroupsViewController {
    @objc private func handleCreateGroup(_ sender: UIBarButtonItem) {
        let viewModel = CreateGroupViewModel()
        let createGroupViewController = CreateGroupViewController.create(with: viewModel)
        self.present(createGroupViewController, animated: true, completion: nil)
    }
}

// MARK: - UISearchResultsUpdating
extension GroupsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        print(searchText)
    }
}
