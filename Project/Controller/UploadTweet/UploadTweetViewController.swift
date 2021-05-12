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
    lazy var addPhotoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Add your photo"
        label.font = .robotoMedium(point: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inputContainerView: UIView = {
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.haveStatusBar ? 34 + 30 : 30)
        containerView.backgroundColor = .white
        containerView.autoresizingMask = [.flexibleHeight]
        
        let addImageButton = UIImageView()
        addImageButton.image = UIImage(named: "ic_chose_image")
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.isUserInteractionEnabled = true
        containerView.addSubview(addImageButton)
        
        addImageButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        addImageButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        addImageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addImageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorView)
        
        seperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        containerView.addSubview(self.addPhotoLabel)
        
        self.addPhotoLabel.leftAnchor.constraint(equalTo: addImageButton.rightAnchor, constant: 8).isActive = true
        self.addPhotoLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        self.addPhotoLabel.centerYAnchor.constraint(equalTo: addImageButton.centerYAnchor).isActive = true
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage(_:))))
        
        return containerView
    }()
    
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
    
    
//    @objc private func something() {
//        inputContainerView.frame.size.height = 64
//
//        UIView.performWithoutAnimation {
//            //                     self.captionTextView.reloadInputViews()
//            self.reloadInputViews()
//        }
//        //        print(self.inputContainerView.frame.height)
//                self.view.endEditing(true)
//    }
    
    // MARK: - Helpers
    /// for configuring  view options
    
    override var inputAccessoryView: UIView? {
        return self.inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.captionTextView.inputAccessoryView = self.inputContainerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Selectors
    @objc private func handleAddImage(_ sender: UITapGestureRecognizer) {
        print("chose image")
    }
    
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
    
    override func keyboardWillShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {

    }
    
    override func keyboardDidShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }

    override func keyboardHide(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    override func keyboardWillChageFrame(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    func updateInputViewFrame() {
            // calculate the accessory view height based on safe insets
            let newHeight = inputContainerView.safeAreaInsets.bottom + 30
            if newHeight != inputContainerView.frame.size.height {
                inputContainerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: newHeight)
                captionTextView.reloadInputViews()
                self.reloadInputViews()
            }
        }
        
    
}

