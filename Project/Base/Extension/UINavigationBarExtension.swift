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
    
    func update(backroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()

            if let backroundColor = backroundColor {
              appearance.backgroundColor = backroundColor
            }

            // Set empty backgroundImage and shadowImage
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            
            if let titleColor = titleColor {
              appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
            }

            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
        }
    }
}

