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

        changeTitleColor()
        changeBackIcon()
        setCornerRadius()
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
    
    func changeTitleColor() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.titleTextAttributes = textAttributes
    }

    private func changeBackIcon() {
        guard var backButtonBackgroundImage = UIImage(named: "ic_back")?.resized(toWidth: 30) else {
            return
        }
        let insets = UIEdgeInsets(top: 0,
                                  left: backButtonBackgroundImage.size.width - 1,
                                  bottom: 0,
                                  right: 0)
        backButtonBackgroundImage = backButtonBackgroundImage.resizableImage(withCapInsets: insets)

        let barAppearance =
            UINavigationBar.appearance(whenContainedInInstancesOf: [BaseNavigationController.self])
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        barAppearance.tintColor = .white
    }

     func setCornerRadius() {
        self.view.backgroundColor = .white
        navigationBar.shadowImage = UIImage(color: UIColor.white)
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .white
    }
}
