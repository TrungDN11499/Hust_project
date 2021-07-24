//
//  LoginViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController, ControllerType {
    
    private var viewModel: ViewModelType!
    @IBOutlet weak var contentScrollView: UIScrollView!
    var moveLogoAnimator: UIViewPropertyAnimator!
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var logoImageViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewTop: NSLayoutConstraint!
    @IBOutlet weak var loginFormView: UIView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.loginFormView.transform = CGAffineTransform(scaleX: 0, y: 0)
        addActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // animation.
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.8, delay: 1, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            self.loginFormView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { _ in
            self.setUpMoveLogo()
            self.moveLogoAnimator.startAnimation()
        })
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
        emailTextField.customImageView.image = UIImage(named: "ic_mail")
        passwordTextField.customImageView.image = UIImage(named: "ic_lock")
        passwordTextField.customTextField.placeholder = "password"
        passwordTextField.customTextField.isSecureTextEntry = true
    }

    override func keyboardWillShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        guard let keyBoardHeight = keyboardHeight else { return }
        let keyBoardMaxY = self.view.frame.height - keyBoardHeight
        let contentViewMaxY = self.loginFormView.frame.maxY
        if contentViewMaxY - keyBoardMaxY > 0 {
            self.contentScrollView.setContentOffset(CGPoint(x: 0, y: (contentViewMaxY - keyBoardMaxY) + 15), animated: true)
        }
    }

    override func keyboardHide(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        self.contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

}
// MARK: - ControllerType
extension LoginViewController {
    typealias ViewModelType = LoginViewModel
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = LoginViewController()
        vc.viewModel = viewModel
        let nav = CustomNavigationController(rootViewController: vc)
        return nav
    }
    
    func configure(with viewModel: ViewModelType) {

        self.emailTextField.bind(viewModel.input.email)
        self.passwordTextField.bind(viewModel.input.password)

        self.loginInButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signInDidTap)
            .disposed(by: disposeBag)
        
        self.signUpButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signUpDidTap)
            .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.presentError(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loginResultObservable
            .subscribe(onNext: { [unowned self] (_) in
                self.gotoHomeController()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.signUpResultObservable.subscribe(onNext: { [unowned self] in
            self.handleRegister()
        })
        .disposed(by: disposeBag)
        
        viewModel.isLoading.asObservable().subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else {return}
            self.view.isUserInteractionEnabled = !value
            self.activityIndicator.isHidden = !value
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - Helper
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
        self.moveLogoAnimator.addCompletion { _ in
            self.logoImageViewTop = self.logoImageView.topAnchor.constraint(equalTo: self.loginFormView.topAnchor, constant: 24)
            self.logoImageViewTop.isActive = true
        }
    }

    private func handleRegister() {
        let registrationService = RegistrationService()
        let regiterViewModel = RegisterViewModel(registrationService: registrationService)
        let registrationController = RegisterViewController.create(with: regiterViewModel)
        self.navigationController?.pushViewController(registrationController, animated: true)
    }
}
