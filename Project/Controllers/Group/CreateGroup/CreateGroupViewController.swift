//
//  CreateGroupViewController.swift
//  Triponus
//
//  Created by Be More on 26/05/2021.
//

import UIKit

class CreateGroupViewController: BaseViewController {
        
    // MARK: -- Properties
    @IBOutlet weak var privacyView: BindingView!
    @IBOutlet weak var nameTextField: BindingTextField!
    @IBOutlet weak var privacyTextField: BindingTextField!
    
    private var viewModel: ViewModelType!
    
    private lazy var createButton: BindingButton = {
        let createButton = BindingButton()
        createButton.setTitle("Create Group", for: .normal)
        createButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: .disabled)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        createButton.setBackgroundImage(UIImage(color: UIColor(hexString: "E4E4E4") ?? .lightGray), for: .disabled)
        createButton.setBackgroundImage(UIImage(color: .twitterBlue), for: .normal)
        createButton.isEnabled = false
        return createButton
    }()
    
    private lazy var inputContainerView: UIView = {
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.haveStatusBar ? 34 + 60 : 60)
        containerView.backgroundColor = .white
        containerView.autoresizingMask = [.flexibleHeight]
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor(hexString: "E4E4E4") ?? .lightGray
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorView)
        
        seperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        containerView.addSubview(createButton)
        createButton.anchor(top: containerView.topAnchor,
                            left: containerView.leftAnchor,
                            bottom: containerView.bottomAnchor,
                            right: containerView.rightAnchor,
                            paddingTop: 11,
                            paddingLeft: 10,
                            paddingBottom: 10,
                            paddingRight: 10)
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        return self.inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: -- View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.createButton.layer.cornerRadius = 6
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    override func configureView() {
        super.configureView()
        self.navigationItem.title = "Create group"
    }
    
    override func bindViewModel() {
        self.configure(with: self.viewModel)
    }
    
    @IBAction func handleDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: -- Handle keyboard
    override func keyboardWillShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    override func keyboardHide(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    func updateInputViewFrame() {
        // calculate the accessory view height based on safe insets
        let newHeight = inputContainerView.safeAreaInsets.bottom + 60
        if newHeight != inputContainerView.frame.size.height {
            inputContainerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: newHeight)
            UIView.performWithoutAnimation {
                self.nameTextField.reloadInputViews()
                self.reloadInputViews()
            }
        }
    }
}

// MARK: -- Helpers
extension CreateGroupViewController {
    
}

// MARK: -- ControllerType
extension CreateGroupViewController: ControllerType {
    typealias ViewModelType = CreateGroupViewModel
    
    func configure(with viewModel: ViewModelType) {
        
        self.nameTextField.bind { value in
            self.createButton.isEnabled = self.viewModel.validateInput(name: value, privacy: self.privacyTextField.text ?? "")
        }
        self.privacyTextField.bind { value in
            self.createButton.isEnabled = self.viewModel.validateInput(name: self.nameTextField.text ?? "", privacy: value)
        }
        self.privacyView.bind { sender  in
            print("Chose privacy")
        }
        
        self.viewModel.output.createGroupResult.bind { observable , value  in
            print("Create")
        }
        
        self.createButton.bind { button in
            let name = self.nameTextField.text ?? ""
            let privacy = self.privacyTextField.text ?? ""
            let createGroupParams = CreateGroupParams(privacy: 0, name: name)
            self.viewModel.input.createGroup.value = createGroupParams
        }
        
        self.privacyTextField.text = "Something"
    }
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let groupViewController = CreateGroupViewController()
        groupViewController.modalPresentationStyle = .fullScreen
        groupViewController.viewModel = viewModel
        return groupViewController
    }
}
