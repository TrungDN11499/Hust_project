//
//  MainTabBarController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabBarController: UITabBarController {
    
    // MARK: - Properties
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
    
    let feedsService = FeedsService()
    lazy var feedsViewModel = FeedsViewModel(feedsService: feedsService)
    lazy var feedsViewController = FeedsViewController.create(with: feedsViewModel)
    
    var user: User? {
        didSet {
            guard let nav = self.viewControllers?[0] as? UINavigationController else { return }
            guard let feedsViewController = nav.viewControllers.first as? FeedsViewController else { return }
            feedsViewController.user = user
        }
    }
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.addTarget(self, action: #selector(handleTapActionButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()
        self.fetchUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.actionButton.layer.cornerRadius = self.actionButton.frame.width / 2
    }
    
    // MARK: - API
    
    private func fetchUser() {
        UserService.shared.fetchUser { user in
            self.user = user
        }
    }
    
    // MARK: - Selector
    
    @objc private func handleTapActionButton(_ sender: UIButton) {

        
        switch self.buttonConfig {
        case .message:
        print("Message.")
        case .tweet:
            guard let user = self.user else { return }
            let uploadTweetViewModel = UploadTweetViewModel(.tweet, user: user)
            let controller = UploadTweetViewController.create(with: uploadTweetViewModel) as! UploadTweetViewController
            controller.delegate = feedsViewController as? UploadTweetViewControllerDelegate
            let nav = CustomNavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.delegate = self
        
        self.view.addSubview(self.actionButton)
        self.actionButton.anchor(bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
    }
    
    /// configure.
    private func configureViewController() {
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundImage = UIImage(color: UIColor.white)
    
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        self.view.backgroundColor = .mainBackgroundColor
        
        let exploreViewController = ExploreViewController()
        let notificationsViewController = NotificationsViewController()
        let conversationsViewController = ConversationsViewController()
        
        let tabBarData: [(UIViewController, UIImage)] = [
            (feedsViewController, UIImage(named: "home_unselected")!),
            (exploreViewController, UIImage(named: "search_unselected")!),
            (notificationsViewController, UIImage(named: "ic_heart")!),
            (conversationsViewController, UIImage(named: "ic_mail_outline_white_2x-1")!)
        ]
        
        self.viewControllers = tabBarData.map({ (vc, image) -> CustomNavigationController in
            return self.templateNavigationController(image: image, rootViewController: vc)
        })
        
//        self.viewControllers = tabBarData.map({ (vc, image) -> UINavigationController in
//            return self.templateNavigationController(image: image, rootViewController: vc)
//        })
        self.configureUI()
    }
    
    /// create navigation bar.
    private func templateNavigationController(image: UIImage, rootViewController: UIViewController) -> CustomNavigationController {
        let nav = CustomNavigationController(rootViewController: rootViewController)
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        return nav
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = self.viewControllers?.firstIndex(of: viewController)
        let image = index == 3 ? #imageLiteral(resourceName: "ic_mail_outline_white_2x-1") : #imageLiteral(resourceName: "new_tweet")
        self.actionButton.setImage(image, for: .normal)
        self.buttonConfig = index == 3 ? .message : .tweet
    }
}
