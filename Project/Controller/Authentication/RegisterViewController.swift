//
//  RegisterViewController.swift
//  Triponus
//
//  Created by admin on 05/05/2021.
//

import UIKit

class RegisterViewController: BaseViewController, ControllerType {
    
    private var viewModel: ViewModelType!
    @IBOutlet weak var registerFormView: UIView!

    @IBOutlet weak var updateImageButton: BindingButton!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
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
        self.addInputAccessoryForTextFields(textFields: [self.emailTextField.customTextField, self.passwordTextField.customTextField, self.fullNameTextField.customTextField, self.userNameTextField.customTextField], dismissable: true, previousNextable: true)
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
        emailTextField.customImageView.image = UIImage(named: "mail-2 1")
        passwordTextField.customImageView.image = UIImage(named: "lock 1")
        passwordTextField.customTextField.placeholder = "password"
        userNameTextField.customImageView.image = UIImage(named: "user 1")
        userNameTextField.customTextField.placeholder = "username"
        fullNameTextField.customImageView.image = UIImage(named: "user 1")
        fullNameTextField.customTextField.placeholder = "fullname"
    }
}
// MARK: ControllerType
extension RegisterViewController {
    typealias ViewModelType = RegisterViewModel
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = RegisterViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    func configure(with viewModel: ViewModelType) {
        self.emailTextField.customTextField.bind(callBack: { viewModel.input.email.value = $0 })
        self.passwordTextField.customTextField.bind(callBack: { viewModel.input.password.value = $0 })
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