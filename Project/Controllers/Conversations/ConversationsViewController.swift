//
//  ConversationsViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit
import Firebase

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class ConversationsViewController: BaseViewController, NewMessageControllerDelegate {
    func showChat(with user: User) {
        let chatLogViewController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogViewController.user = user
        let nav = UINavigationController(rootViewController: chatLogViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    
    let cellId = "cellId"
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var timer: Timer?
    
    // MARK: - Properties
    private lazy var MessageTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    
    private lazy var noConversationsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No Conversations"
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        label.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return label
    }()
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(MessageTableView)
        self.MessageTableView.addConstraintsToFillView(self.view)
        observeUserMessages()
        self.configureViewController()
    }
    
    override func configureView() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_back"), style: .done, target: self, action: #selector(dismissSelf))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(handleNewConversation))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleNewConversation() {
        let conversationViewController = NewMessageController()
        conversationViewController.delegate = self
        let nav = UINavigationController(rootViewController: conversationViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Helpers
    private func configureViewController() {
        self.navigationItem.title = "Messages"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.darkText]
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let message = self.messages[indexPath.row]

        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in

                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }

                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()

            })
        }
    }

    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in

            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in

                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)

            }, withCancel: nil)

        }) { Error in
            
            self.view.addSubview(self.noConversationsLabel)
            self.noConversationsLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.noConversationsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        }
    }

    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)

        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)

                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }

                self.attemptReloadOfTable()
            }

        }, withCancel: nil)
    }

    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }

    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in

            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })

        DispatchQueue.main.async(execute: {
            self.MessageTableView.reloadData()
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserMessageCell
        cell.contentView.isUserInteractionEnabled = true
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]

        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }

        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }

            let user = User(uid: chatPartnerId, dictionary: dictionary)
            self.showChatControllerForUser(user)

        }, withCancel: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }


    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        let nav = UINavigationController(rootViewController: chatLogController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

