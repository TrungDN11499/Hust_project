//
//  UINavigationBarExtension.swift
//  Triponus
//
//  Created by Be More on 14/05/2021.
//

import UIKit

extension UINavigationBar {
    func applyNavBarCornerRadius(radius: CGFloat) {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let navBarHeight = self.frame.height

        let path = UIBezierPath().bottomCornerPath(width: UIScreen.main.bounds.width, height: navBarHeight, statusHeight: statusHeight, radius: radius)

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func applyNavBarCornerRadius(with additionHeight: CGFloat, radius: CGFloat) {
        let statusHeight = UIApplication.shared.statusBarFrame.height
        let navBarHeight = self.frame.height + additionHeight

        let path = UIBezierPath().bottomCornerPath(width: UIScreen.main.bounds.width, height: navBarHeight, statusHeight: statusHeight, radius: radius)

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

