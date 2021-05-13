//
//  RegisterViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    private var viewModel: ViewModelType!
    @IBOutlet weak var registerFormView: UIView!

    @IBOutlet weak var updateImageButton: BindingButton!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var comfirmPasswordField: CustomTextField!
    @IBOutlet weak var userNameTextField: CustomTextField!
    @IBOutlet weak var fullNameTextField: CustomTextField!
    @IBOutlet weak var registerButton: BindingButton!
    @IBOutlet weak var logInButton: BindingButton!
    private let imagePicker = UIImagePickerController()
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView()
        act.color = .white
        act.startAnimating()
        act.isHidden = true
        return act
    }()
    
   
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        self.setUpImagePicker()
        self.addInputAccessoryForTextFields(textFields: [self.emailTextField.customTextField, self.passwordTextField.customTextField,self.comfirmPasswordField.customTextField, self.userNameTextField.customTextField, self.fullNameTextField.customTextField], dismissable: true, previousNextable: true)
        addActivityIndicator()
        // Do any additional setup after loading the view.
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.view.isUserInteractionEnabled = true
//    }
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    //MARK: handleFunction
   
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
    //MARK: setUpTextField
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
        self.emailTextField.customTextField.bind(callBack: { viewModel.input.email.value = $0 })
        self.passwordTextField.customTextField.bind(callBack: { viewModel.input.password.value = $0 })
        self.comfirmPasswordField.customTextField.bind(callBack: { viewModel.input.confirmPassword.value = $0})
        self.userNameTextField.customTextField.bind(callBack: { viewModel.input.userName.value = $0 })
        self.fullNameTextField.customTextField.bind(callBack: { viewModel.input.fullName.value = $0 })
        
        viewModel.output.errorsObservable.bind { [unowned self] observable, value in
            self.presentMessage(value)
            self.view.isUserInteractionEnabled = true
            self.activityIndicator.isHidden = true
        }
        
        viewModel.output.successObservable.bind { [unowned self] observable, value in
            self.gotoHomeController()
        }
        
        self.registerButton.bind { [unowned self] button in
            self.view.isUserInteractionEnabled = false
            self.activityIndicator.isHidden = false
            viewModel.input.registerDidTap.excecute()
        }
        
        self.logInButton.bind { [unowned self] button in
            self.navigationController?.popViewController(animated: true)
        }
        
        self.updateImageButton.bind { [unowned self] button in
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
}
//MARK: UIImagePickerControllerDelegat
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.viewModel.input.profileImage.value = profileImage
        self.updateImageButton.layer.borderColor = UIColor.twitterBlue.cgColor
        self.updateImageButton.layer.borderWidth = 3
        
        self.updateImageButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension RegisterViewController {
    
    private func setUpImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
    }
}
