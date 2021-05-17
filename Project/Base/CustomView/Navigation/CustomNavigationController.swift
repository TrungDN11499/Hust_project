//
//  CustomNavigationController.swift
//  Triponus
//
//  Created by Be More on 14/05/2021.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
    }
}

class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        changeTitleColor()
        changeBackIcon()
        setCornerRadius()
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
            UINavigationBar.appearance(whenContainedInInstancesOf: [CustomNavigationController.self])
        barAppearance.backIndicatorImage = backButtonBackgroundImage
        barAppearance.backIndicatorTransitionMaskImage = backButtonBackgroundImage
        barAppearance.tintColor = .white
    }

     func setCornerRadius() {
        self.view.backgroundColor = .white
        navigationBar.shadowImage = UIImage(color: UIColor.white)
        navigationBar.barTintColor = .white
        navigationBar.applyNavBarCornerRadius(radius: 12)
        navigationBar.tintColor = .white
    }
}

