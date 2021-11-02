//
//  RegisterViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: BaseViewController {
    
    private var viewModel: ViewModelType!
    @IBOutlet weak var registerFormView: UIView!
    private let disposeBag = DisposeBag()

    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var updateImageButton: UIButton!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var comfirmPasswordField: CustomTextField!
    @IBOutlet weak var userNameTextField: CustomTextField!
    @IBOutlet weak var fullNameTextField: CustomTextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    private let imagePicker = UIImagePickerController()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.color = .white
        act.startAnimating()
        act.isHidden = true
        return act
    }()

    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.setUpImagePicker()
        addActivityIndicator()
    }

    @IBAction func handleChoseImage(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }

    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    // MARK: handleFunction
    private func addActivityIndicator() {
        self.registerFormView.addSubview(self.activityIndicator)
        self.activityIndicator.centerY(inView: self.registerButton)
        self.activityIndicator.anchor(right: self.registerButton.rightAnchor, paddingRight: 10, width: 30, height: 30)
    }

    private func setUpView() {
        registerFormView.layer.cornerRadius = 18
        registerFormView.clipsToBounds = true
        registerButton.layer.cornerRadius = 18
        registerButton.clipsToBounds = true
        setUpTextField()
    }

    // MARK: setUpTextField
    private func setUpTextField() {
        emailTextField.customImageView.image = UIImage(named: "ic_mail")
        passwordTextField.customImageView.image = UIImage(named: "ic_lock")
        passwordTextField.customTextField.placeholder = "password"
        passwordTextField.customTextField.isSecureTextEntry = true
        comfirmPasswordField.customImageView.image = UIImage(named: "ic_lock")
        comfirmPasswordField.customTextField.placeholder = "comfirm password"
        comfirmPasswordField.customTextField.isSecureTextEntry = true
        userNameTextField.customImageView.image = UIImage(named: "ic_user")
        userNameTextField.customTextField.placeholder = "username"
        fullNameTextField.customImageView.image = UIImage(named: "ic_user")
        fullNameTextField.customTextField.placeholder = "fullname"
    }

    override func keyboardWillShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        guard let keyBoardHeight = keyboardHeight else { return }
        let keyBoardMaxY = self.view.frame.height - keyBoardHeight
        let contentViewMaxY = self.registerFormView.frame.maxY
        if contentViewMaxY - keyBoardMaxY > 0 {
            self.contentScrollView.setContentOffset(CGPoint(x: 0, y: (contentViewMaxY - keyBoardMaxY) + 15), animated: true)
        }
    }

    override func keyboardHide(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        self.contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
// MARK: ControllerType
extension RegisterViewController: ControllerType {
    typealias ViewModelType = RegisterViewModel

    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = RegisterViewController()
        vc.viewModel = viewModel
        return vc
    }

    func configure(with viewModel: ViewModelType) {
        self.emailTextField.bind(viewModel.input.email)
        self.passwordTextField.bind(viewModel.input.password)
        self.comfirmPasswordField.bind(viewModel.input.confirmPassword)
        self.userNameTextField.bind(viewModel.input.userName)
        self.fullNameTextField.bind(viewModel.input.fullName)
        
        self.registerButton.rx.tap.asObservable()
            .subscribe(viewModel.input.registerDidTap)
            .disposed(by: disposeBag)

        self.logInButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signUpDidTap)
            .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.presentError(error)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.registerResultObservable
            .subscribe(onNext: { [unowned self] _ in
                self.gotoHomeController()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.gotoLoginResultObservable
            .subscribe(onNext: { [unowned self] in
                self.handleLogin()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading.asObservable().subscribe(onNext: { [weak self] (value) in
            guard let `self` = self else {return}
            self.view.isUserInteractionEnabled = !value
            self.activityIndicator.isHidden = !value
        }).disposed(by: self.disposeBag)
    }
}

// MARK: UIImagePickerControllerDelegate
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.updateImageButton.layer.borderColor = UIColor.twitterBlue.cgColor
        self.updateImageButton.layer.borderWidth = 3
        self.updateImageButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.viewModel.input.profileImage.onNext(profileImage)
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Helpers
extension RegisterViewController {
    private func setUpImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
    }
    
    private func handleLogin() {
        self.navigationController?.popViewController(animated: true)
    }
}
