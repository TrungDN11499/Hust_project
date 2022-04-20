//
//  FeedsHeaderCollectionReusableView.swift
//  Triponus
//
//  Created by Be More on 24/05/2021.
//

import UIKit
import SDWebImage

protocol FeedsHeaderCollectionReusableViewDelegate: AnyObject {
    func feedHeaderCollectionView(showProfileOf user: User, view: FeedsHeaderCollectionReusableView)
    func feedHeaderCollectionView(user: User, tweet view: FeedsHeaderCollectionReusableView)
    func feedHeaderCollectionView(message view: FeedsHeaderCollectionReusableView)
}

class FeedsHeaderCollectionReusableView: UICollectionReusableView {

    // MARK: - Properties
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tweetView: UIView!
    
    weak var delegate: FeedsHeaderCollectionReusableViewDelegate?
    
    var user: User? {
        didSet {
            self.setUpViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowProfile(_:))))
        tweetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTweet(_:))))
        DispatchQueue.main.async {
            self.containerView.roundCorners([.bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    @objc private func handleShowProfile(_ sender: UITapGestureRecognizer) {
        guard let user = self.user else { return }
        self.delegate?.feedHeaderCollectionView(showProfileOf: user, view: self)
    }
    
    @objc private func handleTweet(_ sender: UITapGestureRecognizer) {
        guard let user = self.user else { return }
        self.delegate?.feedHeaderCollectionView(user: user, tweet: self)
    }
    
    @IBAction func handleMessage(_ sender: UIButton) {
        self.delegate?.feedHeaderCollectionView(message: self)
    }
}

// MARK: - Helpers
extension FeedsHeaderCollectionReusableView {
    private func setUpViews() {
        guard let user = self.user else { return }
        guard let imageUrl = URL(string: user.profileImageUrl) else { return }
        self.avatarImageView.sd_setImage(with: imageUrl)
    }
}
