//
//  FeedsViewController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet

class FeedsViewController: BaseViewController, ControllerType {
  
    // MARK: - Properties
    private var viewModel: ViewModelType!
        
    private lazy var feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collecionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecionView.backgroundColor = .mainBackgroundColor
        collecionView.delegate = self
        collecionView.dataSource = self
        collecionView.emptyDataSetSource = self
        collecionView.emptyDataSetDelegate = self
        collecionView.showsVerticalScrollIndicator = false
        return collecionView
    }()
    
    var user: User? {
        didSet {
            self.feedCollectionView.reloadData()
        }
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLoading()
        self.viewModel.input.fetchTweets.excecute()
        self.configureViewController()
    }
    
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    override func configureUI() {
        // set up navigation bar
        self.configureViewController()
        self.addUIConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillDisappear(animated)
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
        self.view.backgroundColor = .navigationBarColor
        TweetCollectionViewCell.registerCellByNib(self.feedCollectionView)
        self.feedCollectionView.register(UINib(nibName: "FeedsHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
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
                self.hideLoading()
                self.feedCollectionView.reloadData()
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate
extension FeedsViewController: UICollectionViewDelegate {
   
}

// MARK: - UICollectionViewDataSource
extension FeedsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.output.fetchTweetsResult.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? FeedsHeaderCollectionReusableView else {
            return FeedsHeaderCollectionReusableView()
        }
        header.user = self.user
        header.delegate = self
        return header
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: self.view.frame.width, height: 100)
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
        
        // cell constants
        let cellPadding: CGFloat = 12
        let actionButtonSize: CGFloat = 25
        let optionButtonSize: CGFloat = 20
        let profileImageSize: CGFloat = 40
        let maxTextHeight: CGFloat = 200
        let seperatorHeight: CGFloat = 0.5
        let seeMoreButtonHeight: CGFloat = 17
        let contentTextPadding: CGFloat = 5
        let contentImagePadding: CGFloat = 8
        
        // calculate caption text width
        let textWidth = self.view.frame.width - (optionButtonSize + cellPadding * 2 + contentTextPadding)
        
        // calculate caption text height
        let textHeight = self.viewModel.viewModel(at: indexPath)?.caption.height(withConstrainedWidth: textWidth, font: UIFont.robotoRegular(point: 14)) ?? 0 > maxTextHeight ? maxTextHeight : self.viewModel.viewModel(at: indexPath)?.caption.height(withConstrainedWidth: textWidth, font: UIFont.robotoRegular(point: 14)) ?? 0
             
        // calculate content text height
        var contentHeight: CGFloat = 0
        if textHeight != maxTextHeight {
            contentHeight = profileImageSize + contentTextPadding + textHeight
        } else {
            contentHeight = profileImageSize + contentTextPadding * 2 + textHeight + seeMoreButtonHeight
        }
        
        // calculate image content height
        var imageHeight: CGFloat = 0
        if let images = self.viewModel.viewModel(at: indexPath)?.tweet.images {
            if !images.isEmpty {
                let ratio = images[0].width / images[0].height
                imageHeight = (self.view.frame.width / ratio) + contentImagePadding
            } else {
                imageHeight = 0
            }
        } else {
            imageHeight = 0
        }
        
        // calculate cell height
        let cellHeight: CGFloat =  cellPadding * 3 + actionButtonSize + contentHeight + imageHeight + seperatorHeight
        
        return CGSize(width: self.view.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - TweetCollectionViewCellDelegate
extension FeedsViewController: TweetCollectionViewCellDelegate {
    
    func handleReplyTapped(_ cell: TweetCollectionViewCell) {
        guard let tweet = cell.feedViewModel?.tweet, let index = self.feedCollectionView.indexPath(for: cell) else { return }        
        let uploadTweetViewModel = UploadTweetViewModel(.reply(tweet), user: tweet.user)
        let controller = UploadTweetViewController.create(with: uploadTweetViewModel) as! UploadTweetViewController
        controller.delegate = self
        controller.index = index.item
        let nav = UINavigationController(rootViewController: controller)
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
        guard let tweet = cell.feedViewModel?.tweet, let index = self.feedCollectionView.indexPath(for: cell) else { return }
        let feedsService = FeedsService()
        let feedViewModel = FeedViewModel(tweet, feedsService: feedsService)
        let controller = TweetViewController.create(with: feedViewModel) as! TweetViewController
        controller.delegate = self
        controller.tweetIndex = index
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: -- TweetViewControllerDelegate
extension FeedsViewController: TweetViewControllerDelegate {
    func handleLike(Tweet: Tweet, at index: IndexPath) {
    }
    
    func handleDelete(tweet: Tweet, at index: IndexPath) {
        self.viewModel.input.deleteTweet.value = DeleteParam(tweet: tweet, at: index)
    }
}

// MARK: - UploadTweetViewControllerDelegate
extension FeedsViewController: UploadTweetViewControllerDelegate {
    func handleUpdateNumberOfComment(for index: Int, numberOfComment: Int) {
        self.viewModel.output.fetchTweetsResult.value?[index].tweet.comments.value = numberOfComment
        DispatchQueue.main.async {
            self.feedCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func handleUpdateTweet(tweet: Tweet) {
        let feedViewModel = FeedViewModel(tweet)
        self.viewModel.output.fetchTweetsResult.value?.insert(feedViewModel, at: 0)
    }
}

extension FeedsViewController: FeedsHeaderCollectionReusableViewDelegate {
    func feedHeaderCollectionView(showProfileOf user: User, view: FeedsHeaderCollectionReusableView) {
        let profileController = ProfileController(user)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    func feedHeaderCollectionView(user: User, tweet view: FeedsHeaderCollectionReusableView) {
        let uploadTweetViewModel = UploadTweetViewModel(.tweet, user: user)
        let controller = UploadTweetViewController.create(with: uploadTweetViewModel) as! UploadTweetViewController
        controller.delegate = self
        let nav = CustomNavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func feedHeaderCollectionView(message view: FeedsHeaderCollectionReusableView) {
        // TODO: Message
    }
}

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension FeedsViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return self.getMessageNoData(message: "No post yet");
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "ic_list_empty")
    }
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
