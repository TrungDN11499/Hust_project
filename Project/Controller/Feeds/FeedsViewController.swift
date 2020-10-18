//
//  FeedsViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit
import SDWebImage

private let cellIden = "TweetCell"

class FeedsViewController: UICollectionViewController {

    // MARK: - Properties
    
    private var tweets = [Tweet]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            self.configureLeftBarButton()
        }
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.fetchTweet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helpers
    
    private func fetchTweet() {
        TweetService.shared.fetchTweet { [weak self] tweets in
            guard let `self` = self else { return }
            self.tweets = tweets
        }
    }
    
    private func configureViewController() {
        
        self.collectionView.backgroundColor = .white
        
        guard let logoImage = UIImage(named: "cat") else {
            return
        }
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        self.navigationItem.titleView = imageView
        
        self.collectionView.register(TweetCell.self, forCellWithReuseIdentifier: cellIden)
    }
    
    private func configureLeftBarButton() {
        guard let user = self.user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        guard let imageUrl = URL(string: user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: imageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
}

// MARK: - UICollectionViewDelegate
extension FeedsViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(self.tweets[indexPath.item])
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension FeedsViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIden, for: indexPath) as? TweetCell else { return TweetCell() }
        cell.tweet = self.tweets[indexPath.item]
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = self.tweets[indexPath.item]
        let viewModel = TweetViewModel(tweet)
        let height = viewModel.size(forWidth: self.collectionView.frame.width).height
        return CGSize(width: self.collectionView.frame.width, height: height + 72)
    }
}

// MARK: - TweetCellDelegate
extension FeedsViewController: TweetCellDelegate {
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let uploadTweetController = UploadTweetController(config: .reply(tweet), user: tweet.user)
        let nav = UINavigationController(rootViewController: uploadTweetController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell, at indexpath: IndexPath) {
        guard let user = cell.tweet?.user else { return }
        let profileComtroller = ProfileController(user)
        self.navigationController?.pushViewController(profileComtroller, animated: true)
    }
}
