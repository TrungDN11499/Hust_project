//
//  NotificationTBVCell.swift
//  Triponus
//
//  Created by admin on 16/05/2021.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func didTapProfileImage(_ cell: NotificationTBVCell)
    func didTapFollow(_ cell: NotificationTBVCell)
}
class NotificationTBVCell: UITableViewCell {
    // MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var notification: NotificationModel? {
        didSet { self.configure() }
    }
    
    @IBOutlet weak var notifyLabel: UILabel!
    @IBOutlet weak var userIamgeView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }
    private func setLayout() {
        self.selectionStyle = .none
        
        self.actionButton.borderWidth = 1
        self.actionButton.borderColor = UIColor(rgb: 0x009BE7)
        self.actionButton.layer.cornerRadius = 12
        self.actionButton.clipsToBounds = true
        
        self.userIamgeView.layer.cornerRadius = self.userIamgeView.frame.height / 2
        self.userIamgeView.borderWidth = 1
        self.userIamgeView.borderColor = UIColor(rgb: 0xF2F5FE)
        self.userIamgeView.contentMode = .scaleAspectFill
        self.userIamgeView.clipsToBounds = true
        self.userIamgeView.isUserInteractionEnabled = true
        self.userIamgeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleShowProfile(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func handleActionButton(_ sender: UIButton) {
        self.delegate?.didTapFollow(self)
    }
    
    // MARK: - Selectors
    
    @objc private func handleShowProfile(_ sender: UIImageView) {
        self.delegate?.didTapProfileImage(self)
    }

    // MARK: - Helpers
    
    private func configure() {
        guard let notification = self.notification else { return }
        let viewModel = NotificationViewModel(notification)
        self.userIamgeView.sd_setImage(with: viewModel.profileImageUrl, completed: nil)
        notifyLabel.attributedText = viewModel.notificationText
        self.actionButton.isHidden = viewModel.shouldHideFollowButton
        self.actionButton.setTitle(viewModel.followButtonText, for: .normal)
//        if notification.user.isFollowed {
//            self.actionButton.setTitle("Following", for: .normal)
//        } else {
//            self.actionButton.setTitle("Follow", for: .normal)
//        }
    }
}
