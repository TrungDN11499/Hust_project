//
//  EditProfileViewController.swift
//  Triponus
//
//  Created by admin on 30/05/2021.
//

import UIKit

protocol EditProfileControllerDelegate: AnyObject {
    func controller(_ controller: EditProfileViewController, wantToUpdate user: User)
}

class EditProfileViewController: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var editTableView: UITableView!
    var user : User? 
    private var selectedImage: UIImage? {
        didSet {
            self.userImageView.image = selectedImage
        }
    }
    private let imagePicker = UIImagePickerController()
    private var userInfoChange: Bool = false
    weak var delegate: EditProfileControllerDelegate?
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureImagePicker()
    }
    func setUpView() {
        headerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        self.editTableView.register(EditProfileCell.self, forCellReuseIdentifier: "cellIden")
        editTableView.separatorStyle = .none
        editTableView.delegate = self
        editTableView.dataSource = self
        
        let imageUrl = URL(string: self.user?.profileImageUrl ?? "")
        self.userImageView.sd_setImage(with: imageUrl, completed: nil)
    }
    private func configureImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
    }

    @IBAction func handleBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func handleDoneButton(_ sender: UIButton) {
        self.view.endEditing(true)
        guard imageChanged || userInfoChange else { return }
        self.updateUserData()
    }
    @IBAction func changeAvatarButton(_ sender: UIButton) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    // MARK: - Api.
    
    private func updateUserData() {
        
        if imageChanged && !userInfoChange {
            self.updateProfileImage()
        }
        
        if !imageChanged && userInfoChange {
            UserService.shared.saveUserData(user: self.user!) { [weak self] err, ref  in
                guard let `self` = self else { return }
//                self.delegate?.controller(self, wantToUpdate: self.user!)
            }
        }
        
        if imageChanged && userInfoChange {
            UserService.shared.saveUserData(user: self.user!) { [weak self] err, ref  in
                guard let `self` = self else { return }
                self.updateProfileImage()
            }
        }
        let alert = UIAlertController(title: nil, message: "Update Successfully", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Done", style: .cancel) { action in }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateProfileImage() {
        guard let image = self.selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { [weak self] urlString in
            guard let `self` = self else { return }
            self.user!.profileImageUrl = urlString
            self.delegate?.controller(self, wantToUpdate: self.user!)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        self.dismiss(animated: true, completion: nil)
    }
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileControllerDelegate.
extension EditProfileViewController {
    
    func controller(_ controller: EditProfileViewController, wantToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
    }
}

// MARK: - UITableViewDelegate.

extension EditProfileViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let options = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return options == .bio ? 140.0 : 60.0
    }
}

// MARK: - UITableViewDataSource.

extension EditProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = editTableView.dequeueReusableCell(withIdentifier: "cellIden", for: indexPath) as? EditProfileCell else {
            return EditProfileCell()
        }
        guard let options = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.delegate = self
        cell.viewModel = EditProfileViewModel(user: self.user!, options: options)
        if indexPath.row == EditProfileOptions.allCases.count - 1 {
            cell.lineView.isHidden = true
        }
        return cell
    }
}

// MARK: - EditProfileCellDelegate

extension EditProfileViewController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        self.userInfoChange = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        switch viewModel.options {
        case .fullName:
            guard let fullName = cell.infoTextField.text else { return }
            user?.fullName = fullName
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user?.username = username
        case .bio:
            guard let bio = cell.bioTextView.text else { return }
            user?.bio = bio
        }
    }
}

