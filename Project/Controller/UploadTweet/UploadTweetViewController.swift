//
//  UploadTweetViewController.swift
//  Triponus
//
//  Created by Be More on 07/05/2021.
//

import UIKit
import ActiveLabel

protocol UploadTweetViewControllerDelegate: AnyObject {
    func handleUpdateNumberOfComment(for index: Int, numberOfComment: Int)
    func handleUpdateTweet(tweet: Tweet)
}

class UploadTweetViewController: BaseViewController {
    
    // MARK: - Properties
    
    weak var delegate: UploadTweetViewControllerDelegate?
    
    @IBOutlet weak var captionTextView: CaptionTextView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var uploadImageViewHeightConstraint: NSLayoutConstraint!
    
    private let user: User! = nil
    
    private var index = Int()
    
    private let config: UploadTweetConfiguration! = nil
    
    private lazy var viewModel = UploadTweetViewModel(self.config)
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUpload(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Selectors
    @objc private func handleDissmiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleUpload(_ sender: UIButton) {
        guard let caption = self.captionTextView.text else { return }
        
        if caption.isEmpty {
            return
        }
        
        TweetService1.shared.upload(caption: caption, type: self.config) { [weak self] error, tweetId, numberOfComments, data in
            guard let `self` = self else { return }
            if error != nil {
                return
            }
            
            if case .reply(let tweet) = self.config {
                self.delegate?.handleUpdateNumberOfComment(for: self.index, numberOfComment: numberOfComments)
                NotificationService.shared.uploadNotification(.reply, tweet: tweet)
            } else  {
                REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    guard let uid = dictionary["uid"] as? String else { return }
                    let tweetId = snapshot.key
                    
                    UserService.shared.fetchUser(userId: uid) { user in
                        guard let user = user else { return }
                        let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                        self.delegate?.handleUpdateTweet(tweet: tweet)
                    }
                }
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Api
    
    // MARK: - Helpers
    override func configureView() {
        super.configureView()
        self.configureNavigationBar()
    }
    
    /// set up navigation bar.
    private func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDissmiss(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.uploadButton)
    }
    
}

