//
//  SplashViewController.swift
//  Project III
//
//  Created by Be More on 14/03/2021.
//

import UIKit

// MARK: - Properties
class SplashViewController: BaseViewController {
    let logoImageViewSize: CGFloat = 120
    
    let logoImageView = UIImageView(image: UIImage(named: "ic_sun"))

    let splashView = UIView()
}

// MARK: - View lifecycles
extension SplashViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logoImageView.contentMode = .scaleAspectFit
        self.logoImageView.clipsToBounds = true
        
        self.view.addSubview(self.splashView)
        self.splashView.addSubview(self.logoImageView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.splashView.frame = self.view.bounds
        self.logoImageView.frame = CGRect(x: self.splashView.frame.midX - logoImageViewSize / 2, y: self.splashView.frame.midY - self.logoImageViewSize / 2, width: self.logoImageViewSize, height: self.logoImageViewSize)
        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.height / 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UserService.shared.fetchUser(userId: nil) { user in
            gUser = user
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let `self` = self else { return }
                self.scaleDownAnimation()
            }
        }
       
    }
}

// MARK: - Helpers

extension SplashViewController {
    private func scaleDownAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.logoImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { (success) in
            self.scaleUpAnimation()
        }
    }
    
    private func scaleUpAnimation() {
        let scaleFactor = self.view.frame.width > self.view.frame.height ? self.view.frame.width / self.logoImageViewSize : self.view.frame.height / self.logoImageViewSize
        UIView.animate(withDuration: 0.35, delay: 0.1, options: .curveEaseIn) {
            self.logoImageView.transform = CGAffineTransform(scaleX: scaleFactor * 1.5, y: scaleFactor * 1.5)
            self.logoImageView.alpha = 0
        } completion: { (success) in
            self.removeSplashView()
        }
    }
    
    private func removeSplashView() {
        let homeViewController = MainTabBarController()
        self.changeRootViewControllerTo(rootViewController: homeViewController,
                                        withOption: .transitionCrossDissolve,
                                        duration: 0.2)
    }
    
}
