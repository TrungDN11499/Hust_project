//
//  TweetViewController.swift
//  Triponus
//
//  Created by Be More on 30/05/2021.
//

import UIKit
import FirebaseAuth
import DZNEmptyDataSet
import DTPhotoViewerController

protocol TweetViewControllerDelegate: AnyObject {
    func handleDelete(tweet: Tweet, at index: IndexPath)
    func handleLike(Tweet: Tweet, at index: IndexPath)
}

class TweetViewController: BaseViewController {
    
    // MARK: - Properties
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var optionsImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIView!
    @IBOutlet weak var imageContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var actionSheetLaucher: ActionSheetLaucher!
    
    weak var delegate: TweetViewControllerDelegate?
    var tweetIndex: IndexPath = IndexPath()
    
    private var viewModel: ViewModelType! {
        didSet {
            self.configureView()
        }
    }
    
    private var replies = [Tweet]() {
        didSet {
            self.commentTableView.reloadData()
        }
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Tweet"
        self.fetchReplies()
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowProfile(_:))))
        self.optionsImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowOption(_:))))
        self.tweetImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowImages(_:))))
        self.commentTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        CommentTableViewCell.registerCellByNib(self.commentTableView)
    }
    
    @IBAction func handleLikeTweet(_ sender: UIButton) {
//        self.viewModel.input.likeTweet.value = LikeTweetParam(feedViewModel: self.viewModel, indexPath: self.tweetIndex)
    }
    
    @IBAction func handleComment(_ sender: Any) {
        let uploadTweetViewModel = UploadTweetViewModel(.reply(self.viewModel.tweet), user: self.viewModel.tweet.user)
        let controller = UploadTweetViewController.create(with: uploadTweetViewModel) as! UploadTweetViewController
        controller.delegate = self
        controller.index = self.tweetIndex.item
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    override func configureView() {
        super.configureView()
        guard let feedViewModel = self.viewModel else { return }
        
        if feedViewModel.tweet.user.uid == Auth.auth().currentUser?.uid {
            self.optionsImageView.isHidden = false
        } else {
            self.optionsImageView.isHidden = true
        }
        
        self.captionLabel.text = feedViewModel.caption
        
        self.profileImageView.sd_setImage(with: feedViewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = feedViewModel.userInfoText
        
        self.likeButton.tintColor = feedViewModel.likeButtonTintColor
        self.likeButton.setImage(feedViewModel.likeButtonImage, for: .normal)
        
        feedViewModel.tweet.didLike.bind { (observer, value) in
            dLogDebug(value)
            self.likeButton.setImage(feedViewModel.likeButtonImage(value), for: .normal)
            self.likeButton.tintColor = feedViewModel.likeButtonTintColor(value)
        }
        
        self.likesLabel.text = feedViewModel.likes
        feedViewModel.tweet.likes.bind {  observer, value in
            self.likesLabel.text = feedViewModel.likes
        }
        
        self.commentLabel.text = feedViewModel.comments
        feedViewModel.tweet.comments.bind { observer, value in
            self.commentLabel.text = feedViewModel.comments
        }
        
        if feedViewModel.tweet.images.isEmpty {
            self.imageContentViewHeightConstraint.constant = 0
            self.contentImageView.isHidden = true
        } else {
            self.contentImageView.isHidden = false
            self.tweetImageView.sd_setImage(with: URL(string: feedViewModel.tweet.images[0].imageUrl), completed: nil)
            let imageRatio = feedViewModel.tweet.images[0].width / feedViewModel.tweet.images[0].height
            self.imageContentViewHeightConstraint.constant = UIScreen.main.bounds.width / imageRatio
        }
        
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey] {
                DispatchQueue.main.async {
                    let newsize  = newvalue as! CGSize
                    print(newsize.height)
                    self.tableViewHeightConstraint.constant = newsize.height
                }
                
            }
        }
    }
    
}

// MARK: - Selectors
extension TweetViewController {
    
    @objc private func handleShowProfile(_ sender: UIImageView) {
        let profileController = ProfileController(self.viewModel.tweet.user)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    @objc private func handleShowOption(_ sender: UITapGestureRecognizer) {
        if self.viewModel.tweet.user.isCurrentUser {
            self.actionSheetLaucher = ActionSheetLaucher(self.viewModel.tweet.user)
            self.actionSheetLaucher.delegate = self
            self.actionSheetLaucher.show()
        } else {
            UserService.shared.checkFollowUser(uid: self.viewModel.tweet.user.uid) { isFollowed in
                let tweetUser = self.viewModel.tweet.user
                guard let user = tweetUser else {return}
                user.isFollowed = isFollowed
                self.actionSheetLaucher = ActionSheetLaucher(user)
                self.actionSheetLaucher.delegate = self
                self.actionSheetLaucher.show()
            }
        }
    }
    
    @objc private func handleShowImages(_ sender: UITapGestureRecognizer) {
        let viewController = DTPhotoViewerController(referencedView: self.tweetImageView, image: self.tweetImageView.image ?? UIImage())
        self.present(viewController, animated: true, completion: nil)
        
    }
}

// MARK: - API
extension TweetViewController {
    private func fetchReplies() {
        TweetService1.shared.fetchReply(forTweet: self.viewModel.tweet) { replies in
            self.replies = replies
        }
    }
}

// MARK: - ActionSheetLaucherDelegate
extension TweetViewController: ActionSheetLaucherDelegate {
    func didSelect(option: ActionSheetOption) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { err, ref in
                
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { err, ref in
                
            }
        case .report:
            break
        case .delete:
            self.presentMessage("Do you want to delete this post?") { action in
                self.navigationController?.popViewController(animated: true)
                self.delegate?.handleDelete(tweet: self.viewModel.tweet, at: self.tweetIndex)
            }
            break
        }
    }
}

// MARK: -- ControllerType
extension TweetViewController: ControllerType {
    typealias ViewModelType = FeedViewModel
    
    func configure(with viewModel: ViewModelType) {
        
    }
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let tweetViewController = TweetViewController()
        tweetViewController.viewModel = viewModel
        return tweetViewController
    }
}

// MARK: - UploadTweetViewControllerDelegate
extension TweetViewController: UploadTweetViewControllerDelegate {
    func handleUpdateNumberOfComment(for index: Int, numberOfComment: Int) {
        self.viewModel.tweet.comments.value = numberOfComment
    }
    
    func handleUpdateTweet(tweet: Tweet) {
        return
    }
}

// MARK: - UITableViewDelegate
extension TweetViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension TweetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = CommentTableViewCell.loadCell(tableView, indexPath: indexPath) as? CommentTableViewCell else { return CommentTableViewCell() }
        cell.feedViewModel = FeedViewModel(self.replies[indexPath.row])
        return cell
    }
}


// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension TweetViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.getMessageNoData(message: "No Comment yet");
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ic_list_empty")
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
