//
//  LoginViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit

class LoginViewController: BaseViewController, ControllerType {
    
    private var viewModel: ViewModelType!
    var moveLogoAnimator: UIViewPropertyAnimator!
    
    @IBOutlet weak var logoImageViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var loginFormView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginInButton: BindingButton!
    @IBOutlet weak var signUpButton: BindingButton!
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.loginFormView.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.addInputAccessoryForTextFields(textFields: [self.emailTextField.customTextField, self.passwordTextField.customTextField], dismissable: true, previousNextable: true)
        addActivityIndicator()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        // animation.
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.8, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.loginFormView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (success) in
            self.setUpMoveLogo()
            self.moveLogoAnimator.startAnimation()
        }
    }
    // MARK: setUpFunction
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.color = .white
        act.startAnimating()
        act.isHidden = true
        return act
    }()
    private func addActivityIndicator() {
        self.loginFormView.addSubview(self.activityIndicator)
        self.activityIndicator.centerY(inView: self.loginInButton)
        self.activityIndicator.anchor(right: self.loginInButton.rightAnchor, paddingRight: 10, width: 30, height: 30)
    }
    private func setUpView() {
        loginFormView.layer.cornerRadius = 18
        loginFormView.clipsToBounds = true
        loginInButton.layer.cornerRadius = 18
        loginInButton.clipsToBounds = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setUpTextView()
    }
    private func setUpTextView() {
        emailTextField.customImageView.image = UIImage(named: "mail-2 1")
        passwordTextField.customImageView.image = UIImage(named: "lock 1")
        passwordTextField.customTextField.placeholder = "password"
        passwordTextField.customTextField.isSecureTextEntry = true
    }

    
}
// MARK: - ControllerType
extension LoginViewController {
    typealias ViewModelType = LoginViewModel
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = LoginViewController()
        vc.viewModel = viewModel
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    func configure(with viewModel: ViewModelType) {
        self.emailTextField.customTextField.bind(callBack: { viewModel.input.email.value = $0 })
        self.passwordTextField.customTextField.bind(callBack: { viewModel.input.password.value = $0 })
        
        viewModel.output.errorsObservable.bind { [unowned self] observable, value in
            self.presentMessage(value)
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.isHidden = true
        }
        
        viewModel.output.successObservable.bind { [unowned self] observable, value in
            self.gotoHomeController()
        }
        
        self.loginInButton.bind { [unowned self] button in
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.isHidden = false
            viewModel.input.signInDidTap.excecute()
        }
        
        self.signUpButton.bind { [unowned self] button in
            let registrationService = RegistrationService()
            let regiterViewModel = RegisterViewModel(registrationService: registrationService)
            let registrationController = RegistrationController.create(with: regiterViewModel)
            self.navigationController?.pushViewController(registrationController, animated: true)
        }
    }
}
//MARK: Helper
extension LoginViewController {
    
    /// Animation move logo image view
    /// - Returns: Void
    private func setUpMoveLogo() {
        self.logoImageViewCenterY?.isActive = false
        self.logoImageViewCenterY = nil
        self.moveLogoAnimator = UIViewPropertyAnimator(duration: 2, curve: .easeIn, animations: nil)
        self.moveLogoAnimator.addAnimations({
            self.logoImageView.frame.origin.y = 24
            self.loginFormView.backgroundColor = UIColor(white: 1, alpha: 0.85)
        }, delayFactor: 0.2) // delay the start of animation by 0.2 * 2 seconds.
        
        moveLogoAnimator.addAnimations({
            self.emailTextField.alpha = 1
        }, delayFactor: 0.6) // delay the start of animation by 0.6 * 2 seconds.
        
        moveLogoAnimator.addAnimations({
            self.passwordTextField.alpha = 1
        }, delayFactor: 0.7) // delay the start of animation by 0.7 * 2 seconds.
        
        moveLogoAnimator.addAnimations({
            self.loginInButton.alpha = 1
            self.registerView.alpha = 1
        
        }, delayFactor: 0.8) // delay the start of animation by 0.8 * 2 seconds.
        self.moveLogoAnimator.addCompletion { final in
            self.logoImageViewTop = self.logoImageView.topAnchor.constraint(equalTo: self.loginFormView.topAnchor, constant: 24)
            self.logoImageViewTop.isActive = true
        }
    }
}
