//
//  LoginViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginFormView: UIView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginInButton: UIButton!
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }
    // MARK: setUpFunction
    private func setUpView() {
        loginFormView.layer.cornerRadius = 18
        loginFormView.clipsToBounds = true
        loginInButton.layer.cornerRadius = 18
        loginInButton.clipsToBounds = true
        setUpTextView()
    }
    private func setUpTextView() {
        emailTextField.customImageView.image = UIImage(named: "mail-2 1")
        passwordTextField.customImageView.image = UIImage(named: "lock 1")
        passwordTextField.customTextField.placeholder = "password"
    }
    @IBAction func handleLoginButton(_ sender: UIButton) {
    }
    @IBAction func handleSignUpButton(_ sender: UIButton) {
    }
    
}
