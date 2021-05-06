//
//  TweetCollectionViewCell.swift
//  Project
//
//  Created by Be More on 07/04/2021.
//

import UIKit
import FirebaseAuth

protocol TweetCollectionViewCellDelegate: AnyObject {
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell)
    func handleReplyTapped(_ cell: TweetCollectionViewCell)
    func handleLikeTweet(_ cell: TweetCollectionViewCell)
    func handleDeletePost(_ cell: TweetCollectionViewCell)
    func handleShowContent(_ cell: TweetCollectionViewCell)
}

class TweetCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var optionsImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var seeMoreButton: UIButton!
    
    var needDelete: Bool = false
    
    weak var delegate: TweetCollectionViewCellDelegate?
    
    // MARK: - Properties
    
    var feedViewModel: FeedViewModel? {
        didSet {
            configureData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowProfile(_:))))
        self.optionsImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDelete(_:))))
        self.contentStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowContent(_:))))
        self.captionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowContent(_:))))
    }
    
    @IBAction func handleLike(_ sender: UIButton) {
        self.delegate?.handleLikeTweet(self)
    }
    
    @IBAction func handleComment(_ sender: UIButton) {
        self.delegate?.handleReplyTapped(self)
    }
    
    @IBAction func handleSeeMore(_ sender: UIButton) {
        self.delegate?.handleShowContent(self)
    }
    
    @objc private func handleShowProfile(_ sender: UIImageView) {
        self.delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleDelete(_ sender: UITapGestureRecognizer) {
        self.delegate?.handleDeletePost(self)
    }
    
    @objc private func handleShowContent(_ sender: UITapGestureRecognizer) {
        self.delegate?.handleShowContent(self)
    }
}

// MARK: - Helpers.
extension TweetCollectionViewCell {
    private func configureData() {
        guard let feedViewModel = self.feedViewModel else { return }
        
        if self.needDelete && (feedViewModel.tweet.user.uid == Auth.auth().currentUser?.uid) {
            self.optionsImageView.isHidden = false
        } else {
            self.optionsImageView.isHidden = true
        }
        
        self.seeMoreButton.isHidden = feedViewModel.hideSeeMore
        
        self.captionLabel.text = feedViewModel.caption
    
        self.profileImageView.sd_setImage(with: feedViewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = feedViewModel.userInfoText
                
        self.likeButton.tintColor = feedViewModel.likeButtonTintColor
        self.likeButton.setImage(feedViewModel.likeButtonImage, for: .normal)
        feedViewModel.tweet.didLike.bind { [unowned self] (observer, value) in
            dLogDebug(value)
            self.likeButton.setImage(feedViewModel.likeButtonImage(value), for: .normal)
            self.likeButton.tintColor = feedViewModel.likeButtonTintColor(value)
        }
        
        self.likesLabel.text = feedViewModel.likes
        feedViewModel.tweet.likes.bind { [unowned self] observer, value in
            self.likesLabel.text = feedViewModel.likes
        }
        
        self.commentLabel.text = feedViewModel.comments
        feedViewModel.tweet.comments.bind { [unowned self] observer, value in
            self.commentLabel.text = feedViewModel.comments
        }
        
        self.replyLabel.text = feedViewModel.replyText
        
        self.replyLabel.isHidden = feedViewModel.shouldHideReplyLabel
        
    }
}
