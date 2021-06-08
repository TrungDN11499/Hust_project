//
//  ProfileController.swift
//  Project
//
//  Created by Be More on 10/15/20.
//

import UIKit
import FirebaseAuth

private let collectionHeaderIden = "ProfileHeaderView"

class ProfileController: UICollectionViewController {
    
    
    
    // MARK: - Properties
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    private var tweets = [Tweet]()
    
    private var likedTweets = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch self.selectedFilter {
        case .tweets:
            return self.tweets
        case .likes:
            return self.likedTweets
        }
    }
    
    private var user: User?
    
    // MARK: - Lifecycles
    
    init(_ user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        self.user = nil
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.shared.showLoading(inView: self.view)
        self.configureCollectionView()
        self.fetchTweets()
        self.fetchLikeTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isHidden = true
        self.collectionView.backgroundColor = .mainBackgroundColor
        self.checkIfUserIsFollowing()
        self.fetchUserStats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Selectors
    
    // MARK: - API
    
    private func fetchTweets() {
        guard let user = self.user else { return }
        TweetService1.shared.fetchTweets(forUser: user) { [weak self] tweets in
            guard let `self` = self else { return }
            self.tweets = tweets
            self.collectionView.reloadData()
            Helper.shared.hideLoading(inView: self.view)
        }
    }
    
    private func fetchLikeTweets() {
        guard let user = self.user else { return }
        TweetService1.shared.fetchLike(forUser: user) { [weak self]  in
            guard let `self` = self else { return }
            self.likedTweets = $0
        }
    }
        
    private func checkIfUserIsFollowing() {
        guard let user = self.user else { return }
        UserService.shared.checkFollowUser(uid: user.uid) { [weak self] isFollowed in
            guard let `self` = self else { return }
            self.user?.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUserStats() {
        guard let user = self.user else { return }
        UserService.shared.fetchUserStats(uid: user.uid) { [weak self] stats in
            guard let `self` = self else { return }
            self.user?.stats = stats
            
            self.collectionView.reloadData()
            
        }
    }
    
    // MARK: - Helpers
    
    private func configureCollectionView() {
        self.collectionView.backgroundColor = .white
        
        self.collectionView.contentInsetAdjustmentBehavior = .never
        
        TweetCollectionViewCell.registerCellByNib(self.collectionView)
        
        self.collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: collectionHeaderIden)
        
        guard let tabBarHeight = self.tabBarController?.tabBar.frame.height else { return }
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
    }
    
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = TweetController(self.currentDataSource[indexPath.item])
//        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let cellHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionHeaderIden, for: indexPath) as? ProfileHeaderView else {
            return ProfileHeaderView()
        }
        
        if let user = self.user {
            cellHeader.user = user
        }
        cellHeader.delegate = self
        
        return cellHeader
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = TweetCollectionViewCell.loadCell(collectionView, indexPath: indexPath) as? TweetCollectionViewCell else {
            return TweetCollectionViewCell()
        }
        
        cell.feedViewModel = FeedViewModel(self.currentDataSource[indexPath.item])
        cell.needDelete = false

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: 350)
    }
    
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
        let textHeight = self.currentDataSource[indexPath.item].caption.height(withConstrainedWidth: textWidth, font: UIFont.robotoRegular(point: 14)) > maxTextHeight ? maxTextHeight : self.currentDataSource[indexPath.item].caption.height(withConstrainedWidth: textWidth, font: UIFont.robotoRegular(point: 14))
             
        // calculate content text height
        var contentHeight: CGFloat = 0
        if textHeight != maxTextHeight {
            contentHeight = profileImageSize + contentTextPadding + textHeight
        } else {
            contentHeight = profileImageSize + contentTextPadding * 2 + textHeight + seeMoreButtonHeight
        }
        
        // calculate image content height
        var imageHeight: CGFloat = 0
        let images = self.currentDataSource[indexPath.item].images
        if !images.isEmpty {
            let ratio = images[0].width / images[0].height
            imageHeight = (self.view.frame.width / ratio) + contentImagePadding
        } else {
            imageHeight = 0
        }
        // calculate cell height
        let cellHeight: CGFloat =  cellPadding * 3 + actionButtonSize + contentHeight + imageHeight + seperatorHeight
        
        return CGSize(width: self.view.frame.width, height: cellHeight)
    }
    
}

// MARK: - ProfileHeaderViewDelegate
extension ProfileController: ProfileHeaderViewDelegate {
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleEditFollowProfile(_ view: ProfileHeaderView) {
        
        guard let user = self.user else { return }
        
        if user.isCurrentUser {
            let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.user = self.user
            self.present(vc, animated: true, completion: nil)
            return
        }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (error, ref) in
                self.user?.isFollowed = false
                
                self.collectionView.reloadData()
                
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (error, ref) in
                self.user?.isFollowed = true
                
                self.collectionView.reloadData()
                NotificationService.shared.uploadNotification(.follow, user: self.user)
            }
        }
        
    }
    
    func profileHeaderView(dissmiss view: ProfileHeaderView) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func gotoLoginController() {
        let loginService = LoginService()
        let loginControllerViewModel = LoginViewModel(loginService: loginService)
        let loginController = LoginViewController.create(with: loginControllerViewModel)
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(view: loginController)
        }
        
        self.changeRootViewControllerTo(rootViewController: loginController,
                                        withOption: .transitionCrossDissolve,
                                        duration: 0.2)
    }
    
}

// MARK: - EditProfileControllerDelegate.
extension ProfileController: EditProfileControllerDelegate {
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            self.gotoLoginController()
        } catch {
            dLogWarning("sign out error")
        }
    }
    
    func controller(_ controller: SettingViewController, wantToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }

    func controller(_ controller: EditProfileViewController, wantToUpdate user: User) {
        self.user = user
        self.collectionView.reloadData()
    }
}
