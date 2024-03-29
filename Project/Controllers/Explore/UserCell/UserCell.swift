//
//  UserCell.swift
//  Project
//
//  Created by Be More on 10/17/20.
//

import UIKit

class UserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            configure()
        }
    }
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.setDimensions(width: 40, height: 40)
        imageView.layer.cornerRadius = 40 / 2
        imageView.backgroundColor = .twitterBlue
        imageView.borderWidth = 1
        imageView.borderColor = UIColor(rgb: 0xC4C4C4)
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Roboto-Medium", size: 14)
        label.textColor = .black
        label.text = "Username"
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.init(name: "Roboto-Regular", size: 12)
        label.textColor = .lightGray
        label.text = "Full Name"
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Lifecycles
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.contentView.backgroundColor = .white
        
        self.contentView.addSubview(self.profileImageView)
        self.profileImageView.centerY(inView: self.contentView,
                                      leftAnchor: self.contentView.leftAnchor,
                                      paddingLeft: 12)
        
        let stackView = UIStackView(arrangedSubviews: [self.fullNameLabel, self.userNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        
        self.contentView.addSubview(stackView)
        stackView.centerY(inView: self.profileImageView,
                          leftAnchor: self.profileImageView.rightAnchor,
                          paddingLeft: 8)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    
    private func configure() {
        guard let user = self.user else { return }
        guard let imageUrl = URL(string: user.profileImageUrl) else { return }
        
        self.profileImageView.sd_setImage(with: imageUrl, completed: nil)
        fullNameLabel.text = user.fullName
        userNameLabel.text = "@\(user.username)"
    }
}
