//
//  SettingTVC.swift
//  Triponus
//
//  Created by admin on 27/05/2021.
//

import UIKit

class SettingTVC: UITableViewCell {

    @IBOutlet weak var imageViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var objectImageView: UIImageView!
    @IBOutlet weak var objectLabel: UILabel!
    @IBOutlet weak var nextArrowImage: UIImageView!
    var setting: SettingModel? {
        didSet {
            guard let unrappedSetting = setting else {return}
            self.objectImageView.image = UIImage(named: unrappedSetting.objectImageString)
            self.objectLabel.text = unrappedSetting.objectLabelString
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.objectImageView.clipsToBounds = true
        self.objectImageView.borderWidth = 2
        self.objectImageView.borderColor = .clear
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
