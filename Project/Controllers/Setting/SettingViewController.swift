//
//  SettingViewController.swift
//  Triponus
//
//  Created by admin on 27/05/2021.
//
import UIKit
import FirebaseAuth


class SettingViewController: UITableViewController {

    // MARK: - Properties
    let settings = SettingObject()
    var user: User? {
        didSet {
            self.tableView.reloadData()
        }
    }

    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUser()
    }
    
    // MARK: - Api
    private func fetchUser() {
        UserService.shared.fetchUser { user in
            self.user = user
        }
    }
    
    
    // MARK: - Selectors
    func handleLogout() {
        do {
            try Auth.auth().signOut()
            self.gotoLoginController()
        } catch {
            dLogWarning("sign out error")
        }
    }
    func gotoLoginController() {
        let loginService = LoginService()
        let loginControllerViewModel = LoginViewModel(loginService: loginService)
        let loginController = LoginViewController.create(with: loginControllerViewModel)
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(view: loginController)
        }
        
        self.changeRootViewControllerTo(rootViewController: loginController,
                                        withOption: .transitionCrossDissolve,
                                        duration: 0.2)
    }

    
    // MARK: - Helpers
    private func configureViewController() {
        self.navigationItem.title = "Settings"
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "SettingTVC", bundle: nil), forCellReuseIdentifier: "cellID")

        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.navigationBarColor.cgColor,UIColor.navigationBarColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)

            if let image = UIImage.getImageFrom(gradientLayer: gradient) {
                let app = UINavigationBarAppearance()
                app.backgroundImage = image
                self.navigationController?.navigationBar.scrollEdgeAppearance = app
                self.navigationController?.navigationBar.standardAppearance = app

            }
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row  {
        case 0:
            guard let user = self.user else { return }
            let profileController = ProfileController(user)
            self.navigationController?.pushViewController(profileController, animated: true)
        case 1:
            let vc = EditProfileViewController(nibName: "EditProfileViewController", bundle: nil)
            vc.modalPresentationStyle = .fullScreen
            vc.user = self.user
            self.present(vc, animated: true, completion: nil)
        case 2:
            let groupViewController = GroupsViewController()
            self.navigationController?.pushViewController(groupViewController, animated: true)
        default:
            let alert = UIAlertController(title: nil, message: "Are your sure you want to log out?", preferredStyle: .actionSheet)
            
            let logoutAction = UIAlertAction(title: "Logout", style: .default) { action in
                self.dismiss(animated: true) {
                    self.handleLogout()
                }
            }
            alert.addAction(logoutAction)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { action in }
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.setting.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as? SettingTVC else {
            return SettingTVC()
        }
        if indexPath.item == 0 {
            let imageUrl = URL(string: self.user?.profileImageUrl ?? "")
            cell.objectImageView.sd_setImage(with: imageUrl, completed: nil)
            cell.objectLabel.text = self.user?.fullName ?? ""
            cell.imageViewHeightAnchor.constant = 62
            cell.imageViewWidthAnchor.constant = 62
            cell.objectImageView.layoutIfNeeded()
            cell.objectImageView.layer.cornerRadius = 62/2
            cell.objectImageView.borderColor = UIColor(rgb: 0xF2F5FE)
            cell.objectImageView.contentMode = .scaleAspectFill
        } else {
            let setting = settings.setting[indexPath.item-1]
            cell.setting = setting
            cell.nextArrowImage.isHidden = true
        }
         return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return 48 + 62
        } else {
            return 24*3
        }
        
    }
}


