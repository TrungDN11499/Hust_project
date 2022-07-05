//
//  MainTabBarController.swift
//  Project
//
//  Created by Be More on 9/27/20.
//

import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()

    }
    
    // MARK: - Helpers
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let navigation = self.selectedViewController as? BaseNavigationController
        return navigation?.supportedInterfaceOrientations ?? .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    private func setShadowTabBar() {
        self.tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        self.tabBar.layer.shadowOpacity = 0.5
        self.tabBar.layer.shadowOffset = CGSize.zero
        self.tabBar.layer.shadowRadius = 5
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = false
        self.tabBar.backgroundColor = UIColor.white
    }
    
    /// configure.
    private func configureViewController() {
        
        UserService.shared.fetchUser { user in
            gUser = user
        }
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundImage = UIImage(color: UIColor.white)
    
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        self.view.backgroundColor = .mainBackgroundColor
        
        let exploreViewController = ExploreViewController()
        let settingViewController = SettingViewController()

        let feedsService = FeedsService()
        let feedsViewModel = FeedsViewModel(feedsService: feedsService)
        let feedsViewController = FeedsViewController.create(with: feedsViewModel)

        let tabBarData: [(UIViewController, UIImage)] = [
            (feedsViewController, R.image.ic_home_untouch()!),
            (exploreViewController, R.image.ic_search_untouch()!),
            (settingViewController, R.image.ic_control_untouch()!)
        ]
        
        self.viewControllers = tabBarData.map({ (vc, image) -> BaseNavigationController in
            return self.templateNavigationController(image: image, rootViewController: vc)
        })
        
        self.delegate = self
    }
    
    /// create navigation bar.
    private func templateNavigationController(image: UIImage, rootViewController: UIViewController) -> BaseNavigationController {
        let nav = BaseNavigationController(rootViewController: rootViewController)
        if rootViewController is FeedsViewController {
            nav.setHiddenNavigationBarViewControllers([FeedsViewController.self])
        }
        
        if rootViewController is ExploreViewController {
        }
        
        if rootViewController is SettingViewController {
        }
        
        nav.tabBarItem.image = image
        nav.navigationBar.barTintColor = .white
        return nav
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = self.viewControllers?.firstIndex(of: viewController)
        print(index ?? [])
    }
}
