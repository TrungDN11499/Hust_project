//
//  TweetCollectionViewCell.swift
//  Project
//
//  Created by Be More on 07/04/2021.
//

import UIKit
import FirebaseAuth

protocol TweetCollectionViewCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell)
    func handleReplyTapped(_ cell: TweetCollectionViewCell)
    func handleLikeTweet(_ cell: TweetCollectionViewCell)
    func handleDeletePost(_ cell: TweetCollectionViewCell)
}

class TweetCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var optionsImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
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
    }
    
    @IBAction func handleLike(_ sender: Any) {
        self.delegate?.handleLikeTweet(self)
    }
    
    @IBAction func handleComment(_ sender: Any) {
        self.delegate?.handleReplyTapped(self)
    }
    
    @objc private func handleShowProfile(_ sender: UIImageView) {
        self.delegate?.handleProfileImageTapped(self)
    }
    
    @objc private func handleDelete(_ sender: UIButton) {
        self.delegate?.handleDeletePost(self)
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
        
        self.captionLabel.text = feedViewModel.caption
    
        self.profileImageView.sd_setImage(with: feedViewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = feedViewModel.userInfoText
        
        self.likeButton.tintColor = feedViewModel.likeButtonTintColor
        
        self.likeButton.setImage(feedViewModel.likeButtonImage, for: .normal)
        
        self.replyLabel.text = feedViewModel.replyText
        
        self.replyLabel.isHidden = feedViewModel.shouldHideReplyLabel
        
    }
}
