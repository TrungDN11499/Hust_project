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
    
    /// Set bottom corner radius for navigation bar.
    func setCornerRadius() {
        self.view.backgroundColor = .white
        navigationBar.shadowImage = UIImage(color: UIColor.white)
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .white
    }
    
    /// Change UINavigation bar back icon
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
    
    /// Add gradient color to navigation bar
    /// - Parameters:
    ///   - colors: gradient colors
    ///   - locations:`[NSNumber]`
    ///   - startPoint: `CGPoint`
    ///   - endPoint: `CGPoint`
    func addGradient(with colors: [CGColor], locations: [NSNumber]? = nil, at startPoint: CGPoint, to endPoint: CGPoint) {
        let gradient = CAGradientLayer()
        var bounds = self.navigationBar.bounds

        var statusBarHeight: CGFloat = 0
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        bounds.size.height += statusBarHeight
        gradient.frame = bounds
        gradient.colors = colors
        
        if let locations = locations {
            gradient.locations = locations
        }
        
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint

        if let image = UIImage.getImageFrom(gradientLayer: gradient) {
            let app = UINavigationBarAppearance()
            app.backgroundImage = image
            self.navigationBar.scrollEdgeAppearance = app
            self.navigationBar.standardAppearance = app
        }
    }
}
