//
//  UINavigationController+Extension.swift
//  Triponus
//
//  Created by Be More on 21/04/2022.
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
    
    func changeBackgroundColor(to color: UIColor?) {
        self.navigationBar.barTintColor = color
    }
    
    func changeTintColor(to color: UIColor?) {
        self.navigationBar.tintColor = color
    }
    
    func changeBarTintColor(to color: UIColor?) {
        self.navigationBar.barTintColor = color
    }
    
    func changeTitleColor(to color: UIColor) {
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
    func setSeperatorLineHidden(_ isHidden: Bool) {
        self.navigationBar.setValue(isHidden, forKey: "hidesShadow")
    }
}
