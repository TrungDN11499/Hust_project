//
//  RegistrationController.swift
//  Project
//
//  Created by Be More on 9/29/20.
//

import UIKit
import Firebase

class RegistrationController: BaseViewController, ControllerType {
    
    // MARK: - Properties
    private var viewModel: ViewModelType!

    private let imagePicker = UIImagePickerController()
    
    private lazy var registerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var addPhotoButton: BindingButton = {
        let button = BindingButton()
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .lightGray
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.clipsToBounds = true
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_mail_outline_white_2x-1")
        let view = Utilities().inputContainerView(image: image, textField: self.emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_lock_outline_white_2x")
        let view = Utilities().inputContainerView(image: image, textField: self.passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var fullNameContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_person_outline_white_2x")
        let view = Utilities().inputContainerView(image: image, textField: self.fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var userNameContainerView: UIView = {
        let image = #imageLiteral(resourceName: "ic_person_outline_white_2x")
        let view = Utilities().inputContainerView(image: image, textField: self.usernameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var emailTextField: BindingTextField = {
        let textField = Utilities().textField(withPlaceholder: "Email")
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var passwordTextField: BindingTextField = {
        let textField = Utilities().textField(withPlaceholder: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var fullNameTextField: BindingTextField = {
        let textField = Utilities().textField(withPlaceholder: "Full Name")
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private lazy var usernameTextField: BindingTextField = {
        let textField = Utilities().textField(withPlaceholder: "Username")
        return textField
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.color = .white
        act.startAnimating()
        act.isHidden = true
        return act
    }()
    
    private lazy var signUpButton: BindingButton = {
        let button = BindingButton(controlEvent: .touchUpInside)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.backgroundColor = .twitterBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius =  5
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: BindingButton = {
        let button = Utilities().attributeButton("Already have an account? ", "Log In")
        return button
    }()
    
    // MARK: - Lifecycles
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    override func configureUI() {
        self.setUpImagePicker()
        self.addUIConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.addPhotoButton.layer.cornerRadius = self.addPhotoButton.frame.width / 2
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.viewModel.input.profileImage.value = profileImage
        self.addPhotoButton.layer.borderColor = UIColor.twitterBlue.cgColor
        self.addPhotoButton.layer.borderWidth = 3
        
        self.addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - ControllerType
extension RegistrationController {
    typealias ViewModelType = RegisterViewModel
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = RegistrationController()
        vc.viewModel = viewModel
        return vc
    }
    
    func configure(with viewModel: ViewModelType) {
        self.emailTextField.bind(callBack: { viewModel.input.email.value = $0 })
        self.passwordTextField.bind(callBack: { viewModel.input.password.value = $0 })
        self.usernameTextField.bind(callBack: { viewModel.input.userName.value = $0 })
        self.fullNameTextField.bind(callBack: { viewModel.input.fullName.value = $0 })
        
        viewModel.output.errorsObservable.bind { [unowned self] observable, value in
            self.presentMessage(value)
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.isHidden = true
        }
        
        viewModel.output.successObservable.bind { [unowned self] observable, value in
            self.gotoHomeController()
        }
        
        self.signUpButton.bind { [unowned self] button in
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.isHidden = false
            viewModel.input.registerDidTap.excecute()
        }
        
        self.alreadyHaveAccountButton.bind { [unowned self] button in
            self.navigationController?.popViewController(animated: true)
        }
        
        self.addPhotoButton.bind { [unowned self] button in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
}

// MARK: - Helpers
extension RegistrationController {
    
    private func setUpImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
    }
    
    private func addUIConstraints() {
        // register view contraints
        self.view.addSubview(self.registerView)
        self.registerView.centerX(inView: self.view)
        self.registerView.centerY(inView: self.view, leftAnchor: self.view.leftAnchor, paddingLeft: 32)
        
        self.registerView.addSubview(self.addPhotoButton)
        self.addPhotoButton.centerX(inView: self.registerView, topAnchor: self.registerView.topAnchor)
        self.addPhotoButton.setDimensions(width: 128, height: 128)

        let stackView = UIStackView(arrangedSubviews: [self.emailContainerView,
                                                       self.passwordContainerView,
                                                       self.fullNameContainerView,
                                                       self.userNameContainerView,
                                                       self.signUpButton])

        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually

        self.registerView.addSubview(stackView)
        stackView.anchor(top: self.addPhotoButton.bottomAnchor, left: self.registerView.leftAnchor, bottom: self.registerView.bottomAnchor, right: self.registerView.rightAnchor, paddingTop: 5)

        // activity.
        self.registerView.addSubview(self.activityIndicator)
        self.activityIndicator.centerY(inView: self.signUpButton)
        self.activityIndicator.anchor(right: self.signUpButton.rightAnchor, paddingRight: 10, width: 30, height: 30)
        
        self.view.addSubview(self.alreadyHaveAccountButton)
        self.alreadyHaveAccountButton.anchor(left: self.view.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, paddingLeft: 40)
        self.alreadyHaveAccountButton.centerX(inView: self.view)
        
        self.addInputAccessoryForTextFields(textFields: [self.emailTextField, self.passwordTextField, self.fullNameTextField, self.usernameTextField], dismissable: true, previousNextable: true)
    }
}
