//
//  NewConversationsController.swift
//  Triponus
//
//  Created by Valerian on 07/05/2021.
//

import Foundation
import UIKit

private let cellIden = "UserCell"

protocol NewMessageControllerDelegate: AnyObject {
    func showChat(with user: User)
}

class NewMessageController: UITableViewController {
    
    var conversationController: ConversationsViewController?

    
    // MARK: - Properties
    
    weak var delegate: NewMessageControllerDelegate?
    
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
        self.navigationItem.title = "Messages"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellIden)
        self.tableView.rowHeight = 60
        tableView.separatorStyle = .none
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension NewMessageController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.inSearchMode ? self.filterUsers[indexPath.row] : self.users[indexPath.row]
//        let chatUser = self.users[indexPath.row]
//        self.conversationController?.showChatControllerForUser(chatUser)
        
        self.dismiss(animated: true) {
            self.delegate?.showChat(with: user)
        }
    }
}

// MARK: - UITableViewDataSource

extension NewMessageController {
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
