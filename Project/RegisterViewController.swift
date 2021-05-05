//
//  RegisterViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var registerFormView: UIView!
    @IBOutlet weak var userUpdateImageView: UIImageView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var userNameTextField: CustomTextField!
    @IBOutlet weak var fullNameTextField: CustomTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        // Do any additional setup after loading the view.
    }
    //MARK: handleFunction
    private func setUpView() {
        registerFormView.layer.cornerRadius = 18
        registerFormView.clipsToBounds = true
        registerButton.layer.cornerRadius = 18
        registerButton.clipsToBounds = true
        setUpTextField()
    }
    //MARK: setUpTextField
    private func setUpTextField() {
        emailTextField.customImageView.image = UIImage(named: "mail-2 1")
        passwordTextField.customImageView.image = UIImage(named: "lock 1")
        passwordTextField.customTextField.placeholder = "password"
        userNameTextField.customImageView.image = UIImage(named: "user 1")
        userNameTextField.customTextField.placeholder = "username"
        fullNameTextField.customImageView.image = UIImage(named: "user 1")
        fullNameTextField.customTextField.placeholder = "fullname"
    }
    //MARK: handleRegisterButton
    @IBAction func handleRegisterButton(_ sender: UIButton) {
    }
    
    //MARK: handleLoginButton
    @IBAction func handleLoginButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
