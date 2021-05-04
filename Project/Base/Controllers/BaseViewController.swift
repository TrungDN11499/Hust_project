//
//  BaseViewController.swift
//  Project
//
//  Created by Be More on 10/3/20.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        self.bindViewModel()
        self.configureUI()
    }
    
    // MARK: - Selectors

    @objc private func handleResignFirstResponder() {
        self.view.endEditing(true)
    }
    
    // MARK: - Helpers
    /// for configuring  view options
    func configureView() {
        self.view.backgroundColor = .white
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleResignFirstResponder)))
    }
    
    /// for programmatically configuring UI
    func configureUI() {
        
    }
    
    /// for binding view model
    func bindViewModel() {
        
    }
    
    // go to home viewController
    /// - Returns: Void
    func gotoHomeController() {
        let homeViewController = MainTabBarController()
        self.changeRootViewControllerTo(rootViewController: homeViewController,
                                        withOption: .transitionCrossDissolve,
                                        duration: 0.2)
    }
    
}
