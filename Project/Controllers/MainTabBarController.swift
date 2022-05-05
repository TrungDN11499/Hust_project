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
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureViewController()

    }
    
    // MARK: - Helpers
    
    /// configure.
    private func configureViewController() {
        
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundImage = UIImage(color: UIColor.white)
    
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        
        self.view.backgroundColor = .mainBackgroundColor
        
        let exploreViewController = ExploreViewController()
        let settingViewController = SettingViewController()
//        let notificationsViewController = NotificationsViewController()
//        let bookingViewController = BookingViewController(nibName: "BookingViewController", bundle: nil)

        let feedsViewModel = FeedsViewModel(feedsService: feedsService)
        let feedsViewController = FeedsViewController.create(with: feedsViewModel)

        let tabBarData: [(UIViewController, UIImage)] = [
            (feedsViewController, R.image.ic_home_untouch()!),
            (exploreViewController, R.image.ic_search_untouch()!),
//            (notificationsViewController, UIImage(named: "ic_bell_untouch")!),
//            (bookingViewController, UIImage(named: "ic_booking_untouch")!),
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
