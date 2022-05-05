//
//  BaseNavigationController.swift
//  Triponus
//
//  Created by Be More on 14/05/2021.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    var listViewControllerHiddenNavBar: [UIViewController.Type] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topVC = viewControllers.last {
            //return the status property of each VC, look at step 2
            return topVC.preferredStatusBarStyle
        }
        return .default
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    private func setupUI() {
        self.navigationBar.isTranslucent = false
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.layer.shadowColor = R.color.shadow()?.cgColor
        self.navigationBar.layer.shadowOpacity = 0.8
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        self.navigationBar.layer.shadowRadius = 4
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        
        self.navigationBar.update(backroundColor: .white, titleColor: .black)

        self.navigationBar.titleTextAttributes = [
            .foregroundColor: R.color.darkText()!,
            .font: R.font.robotoMedium(size: 18)!
        ]

        self.changeTintColor(to: R.color.darkText()!)
        self.changeBarTintColor(to: R.color.white()!)
        self.changeBackgroundColor(to: R.color.white()!)
        
        self.delegate = self
    }
    
    /// Set hide navigation bar at view controllers
    /// - Parameter viewControllers: view controllers
    func setHiddenNavigationBarViewControllers(_ viewControllers: [UIViewController.Type]) {
        self.listViewControllerHiddenNavBar = viewControllers
    }
    
    /// Add view controller to navigation bar hidden list
    /// - Parameter viewController: `UIViewController.Type`
    func addHiddenNavigationBarViewController(_ viewController: UIViewController.Type) {
        self.listViewControllerHiddenNavBar.append(viewController)
    }
    
}

// MARK: UINavigationControllerDelegate
extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isHidden = self.listViewControllerHiddenNavBar.first(where: { viewController.isKind(of: $0.self) }) != nil
        navigationController.setNavigationBarHidden(isHidden, animated: true)
    }
}
