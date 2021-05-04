//
//  FeedsViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit
import SDWebImage

class FeedsViewController: BaseViewController, ControllerType {

    // MARK: - Properties
    private var viewModel: ViewModelType!
        
    private lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collecionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecionView.backgroundColor = .white
        collecionView.delegate = self
        collecionView.dataSource = self
        return collecionView
    }()
    
    var user: User? {
        didSet {
            self.configureLeftBarButton()
        }
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.input.fetchTweets.excecute()
        self.configureViewController()
    }
    
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    override func configureUI() {
        // set up navigation bar
        self.configureViewController()
        self.configureLeftBarButton()
        self.addUIConstraints()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    
    // MARK: - Selectors
    @objc private func hanldeRefresh(_ sender: UIRefreshControl) {
        self.viewModel.input.fetchTweets.excecute()
    }
    
    @objc private func handleGoToProfile(_ sender: UIImageView) {
        guard let user = self.user else { return }
        let profileController = ProfileController(user)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    // MARK: -  Api
        
    // MARK: - Helpers
    private func configureViewController() {
        
        self.feedCollectionView.backgroundColor = .white
        
        guard let logoImage = UIImage(named: "ic_sun") else {
            return
        }
        
        let imageView = UIImageView(image: logoImage)
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        self.navigationItem.titleView = imageView
        
        TweetCollectionViewCell.registerCellByNib(self.feedCollectionView)
    }
    
    private func configureLeftBarButton() {
        guard let user = self.user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleGoToProfile(_:))))
        
        guard let imageUrl = URL(string: user.profileImageUrl) else { return }
        
        profileImageView.sd_setImage(with: imageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    private func addUIConstraints() {
        self.view.addSubview(self.feedCollectionView)
        self.feedCollectionView.fillSuperView()
    }
}

// MARK: - ControllerType
extension FeedsViewController {
    typealias ViewModelType = FeedsViewModel
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = FeedsViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    func configure(with viewModel: ViewModelType) {
        viewModel.output.fetchTweetsResult.bind { [unowned self] observable, values in
            DispatchQueue.main.async {
                self.feedCollectionView.refreshControl?.endRefreshing()
                if self.feedCollectionView.refreshControl == nil {
                    let refreshControl = UIRefreshControl()
                    refreshControl.addTarget(self, action: #selector(hanldeRefresh(_:)), for: .valueChanged)
                    self.feedCollectionView.refreshControl = refreshControl
                }
                self.feedCollectionView.reloadData()
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension FeedsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

// MARK: - UICollectionViewDataSource
extension FeedsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.output.fetchTweetsResult.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = TweetCollectionViewCell.loadCell(collectionView, indexPath: indexPath) as? TweetCollectionViewCell else {
            return TweetCollectionViewCell()
        }
        cell.needDelete = true
        cell.delegate = self
        cell.feedViewModel = self.viewModel.viewModel(at: indexPath)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellPadding: CGFloat = 12
        let infoLabelHeight: CGFloat = 17
        let actionButtonSize: CGFloat = 30
        let profileImageSize: CGFloat = 48
        
        let textWidth = self.view.frame.width - (profileImageSize + actionButtonSize + cellPadding * 4)
        let textHeight = self.viewModel.viewModel(at: indexPath)?.caption.height(withConstrainedWidth: textWidth, font: UIFont.systemFont(ofSize: 17)) ?? 0
        
        let contentHeight = (infoLabelHeight + 4 + textHeight) > profileImageSize ? (infoLabelHeight + 4 + textHeight) : profileImageSize
        
        let cellHeight: CGFloat =  cellPadding * 3 + actionButtonSize + contentHeight + 0.5
        
        return CGSize(width: self.feedCollectionView.frame.width, height: cellHeight)
    }
}

// MARK: - TweetCollectionViewCellDelegate
extension FeedsViewController: TweetCollectionViewCellDelegate {
    
    func handleReplyTapped(_ cell: TweetCollectionViewCell) {
        guard let tweet = cell.feedViewModel?.tweet, let index = self.feedCollectionView.indexPath(for: cell) else { return }
        let uploadTweetController = UploadTweetController(config: .reply(tweet), user: tweet.user, delegate: self, index: index.item)
        let nav = UINavigationController(rootViewController: uploadTweetController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTweet(_ cell: TweetCollectionViewCell) {
        guard let index = self.feedCollectionView.indexPath(for: cell), let feedViewModel = cell.feedViewModel else { return }
        self.viewModel.input.likeTweet.value = LikeTweetParam(feedViewModel: feedViewModel, indexPath: index)
    }
    
    func handleProfileImageTapped(_ cell: TweetCollectionViewCell) {
        guard let user = cell.feedViewModel?.tweet.user else { return }
        let profileComtroller = ProfileController(user)
        self.navigationController?.pushViewController(profileComtroller, animated: true)
    }
    
    func handleDeletePost(_ cell: TweetCollectionViewCell) {
        self.presentMessage("Do you want to delete this post?") { action in
            guard let tweet = cell.feedViewModel?.tweet, let index = self.feedCollectionView.indexPath(for: cell) else { return }
            self.viewModel.input.deleteTweet.value = DeleteParam(tweet: tweet, at: index)
        }
    }
    
    func handleShowContent(_ cell: TweetCollectionViewCell) {
        guard let tweet = cell.feedViewModel?.tweet else { return }
        let controller = TweetController(tweet)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UploadTweetControllerDelegate
extension FeedsViewController: UploadTweetControllerDelegate {
    func handleUpdateNumberOfComment(for index: Int) {
        self.viewModel.output.fetchTweetsResult.value?[index].tweet.comments += 1
        DispatchQueue.main.async {
            self.feedCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func handleUpdateTweet(tweet: Tweet) {
        let feedViewModel = FeedViewModel(tweet)
        self.viewModel.output.fetchTweetsResult.value?.insert(feedViewModel, at: 0)
    }
}
