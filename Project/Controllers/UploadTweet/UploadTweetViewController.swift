//
//  UploadTweetViewController.swift
//  Triponus
//
//  Created by Be More on 07/05/2021.
//

import UIKit
import MobileCoreServices
import YPImagePicker

protocol UploadTweetViewControllerDelegate: AnyObject {
    func handleUpdateNumberOfComment(for index: Int, numberOfComment: Int)
    func handleUpdateTweet(tweet: Tweet)
}

class UploadTweetViewController: BaseViewController {
    
    // MARK: - Properties
    lazy var addPhotoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Add your photo"
        label.font = .robotoMedium(point: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var inputContainerView: UIView = {
        let containerView = UIView()
        
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.haveStatusBar ? 34 + 40 : 40)
        containerView.backgroundColor = .white
        containerView.autoresizingMask = [.flexibleHeight]
        
        let addImageButton = UIImageView()
        addImageButton.image = UIImage(named: "ic_chose_image")
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.isUserInteractionEnabled = true
        containerView.addSubview(addImageButton)
        
        addImageButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
        addImageButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        addImageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addImageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorView)
        
        seperatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        containerView.addSubview(self.addPhotoLabel)
        
        self.addPhotoLabel.leftAnchor.constraint(equalTo: addImageButton.rightAnchor, constant: 8).isActive = true
        self.addPhotoLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        self.addPhotoLabel.centerYAnchor.constraint(equalTo: addImageButton.centerYAnchor).isActive = true
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddImage(_:))))
        return containerView
    }()
    
    weak var delegate: UploadTweetViewControllerDelegate?
    
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var captionTextView: CaptionTextView!
    @IBOutlet weak var imageContentView: UIView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var uploadImageViewHeightConstraint: NSLayoutConstraint!
        
    var index = Int()
    
    private var viewModel: ViewModelType!
    
    private lazy var uploadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Upload", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .twitterBlue
        button.frame = CGRect(x: 0, y: 0, width: 70, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUpload(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Helpers
    /// for configuring  view options
    override var inputAccessoryView: UIView? {
        return self.inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captionTextView.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder()
    }
    
    // MARK: - Selectors
    @objc private func handleAddImage(_ sender: UITapGestureRecognizer) {
        
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video, .photo]
        config.library.mediaType = .photoAndVideo
        config.hidesCancelButton = false
        config.library.maxNumberOfItems = 3
        // And then use the default configuration like so:
        let picker = YPImagePicker(configuration: config)
        picker.navigationBar.update(backroundColor: .primary, titleColor: .white)

        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta)
                self.imageContentView.isHidden = false
                self.uploadImageView.image = photo.image
                
                let margin: CGFloat = 12
                let imageRatio = photo.image.size.width / photo.image.size.height
                self.uploadImageViewHeightConstraint.constant = (self.view.frame.width - margin * 2) / imageRatio
                
                // Print exif meta data of original image.
            }
            picker.dismiss(animated: true) {
                self.captionTextView.becomeFirstResponder()
            }
        }
        present(picker, animated: true, completion: nil)
        
//        let imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
//        imagePicker.delegate = self
//        // TODO: turn on sending video.
//        imagePicker.mediaTypes = [kUTTypeImage as String
////                                  , kUTTypeMovie as String
//        ]
//        imagePicker.modalPresentationStyle = .fullScreen
//        self.captionTextView.resignFirstResponder()
//        self.showLoading()
//        present(imagePicker, animated: true) {
//            self.hideLoading()
//        }
    }
    
    @objc private func handleDissmiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleRemoveImage(_ sender: Any) {
        self.uploadImageView.image = nil
        self.imageContentView.isHidden = true
        self.uploadImageViewHeightConstraint.constant = 0
    }
    
    @objc private func handleUpload(_ sender: UIButton) {
        if String.isNilOrEmpty(self.captionTextView.text) && self.uploadImageView.image == nil { return }
        self.captionTextView.resignFirstResponder()
        self.showLoading()
        let caption = self.captionTextView.text ?? ""
        var images = [UIImage]()
        if let image = self.uploadImageView.image {
            images.append(image)
        }
        TweetService1.shared.upload(caption: caption, images: images, type: self.viewModel.config) { [weak self] error, tweetId, numberOfComments, data in
            guard let `self` = self else { return }
            if error != nil {
                return
            }
            
            if case .reply(let tweet) = self.viewModel.config {
                
                self.delegate?.handleUpdateNumberOfComment(for: self.index, numberOfComment: numberOfComments)
                NotificationService.shared.uploadNotification(.reply, tweet: tweet)
            } else  {
                REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    guard let uid = dictionary["uid"] as? String else { return }
                    let tweetId = snapshot.key
                    
                    UserService.shared.fetchUser(userId: uid) { user in
                        guard let user = user else { return }
                        let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                        self.delegate?.handleUpdateTweet(tweet: tweet)
                    }
                }
            }
            self.hideLoading()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Api
    
    // MARK: - Helpers
    override func configureView() {
        super.configureView()
        if case .tweet = self.viewModel.config {
            self.inputContainerView.isHidden = false
        } else {
            self.inputContainerView.isHidden = true
        }
        self.configureNavigationBar()
        self.setData()
    }
    
    /// set up navigation bar.
    private func configureNavigationBar() {
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDissmiss(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.uploadButton)
    }
    
    private func setData() {
        guard let url = URL(string: self.viewModel.user.profileImageUrl) else { return }
        self.profileImageView.sd_setImage(with: url, completed: nil)
        
        self.uploadButton.setTitle(self.viewModel.actionButtonText, for: .normal)
        self.captionTextView.placeHolderLabel.text = self.viewModel.placeholderText
        
        self.infoLabel.attributedText = self.viewModel.userInfoText
        self.replyLabel.isHidden = !self.viewModel.shouldShowReplyLabel
        guard let text = self.viewModel.reply else { return }
        self.replyLabel.text = text
    }
    
    override func keyboardWillShow(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    override func keyboardHide(keyboardHeight: CGFloat?, duration: Double?, keyboardCurve: UInt?) {
        updateInputViewFrame()
    }
    
    func updateInputViewFrame() {
        // calculate the accessory view height based on safe insets
        let newHeight = inputContainerView.safeAreaInsets.bottom + 40
        if newHeight != inputContainerView.frame.size.height {
            inputContainerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: newHeight)
            UIView.performWithoutAnimation {
                self.captionTextView.reloadInputViews()
                self.reloadInputViews()
            }
        }
    }
}

extension UploadTweetViewController: ControllerType {
    
    typealias ViewModelType = UploadTweetViewModel
 
    func configure(with viewModel: ViewModelType) {
        
    }
    
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let vc = UploadTweetViewController()
        vc.viewModel = viewModel
        return vc
    }
}

// MARK: - UIImagePickerControllerDelegate
extension UploadTweetViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
         var selectedImageFromPicker: UIImage?
              
              if let edittedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
                  // set the image.
                  selectedImageFromPicker = edittedImage
              }
              else if let originalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
                  // set the image.
                  selectedImageFromPicker = originalImage
              }
              
              if let selectedImage = selectedImageFromPicker {
                self.imageContentView.isHidden = false
                self.uploadImageView.image = selectedImage
                
                let margin: CGFloat = 12
                let imageRatio = selectedImage.size.width / selectedImage.size.height
                self.uploadImageViewHeightConstraint.constant = (self.view.frame.width - margin * 2) / imageRatio
              }
        self.dismiss(animated: true) {
            self.captionTextView.becomeFirstResponder()
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension UploadTweetViewController: UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            self.captionTextView.becomeFirstResponder()
        }
    }
}

extension UINavigationBar {
    func update(backroundColor: UIColor? = nil, titleColor: UIColor? = nil) {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()

            if let backroundColor = backroundColor {
              appearance.backgroundColor = backroundColor
            }

            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            if let titleColor = titleColor {
              appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
            }

            self.standardAppearance = appearance
            self.scrollEdgeAppearance = appearance
        } else {
        }
    }
}
