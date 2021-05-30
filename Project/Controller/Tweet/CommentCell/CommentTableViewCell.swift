//
//  CommentTableViewCell.swift
//  Triponus
//
//  Created by Be More on 30/05/2021.
//

import UIKit

class CommentTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    var feedViewModel: FeedViewModel? {
        didSet {
            configureData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

// MARK: -- Helpers
extension CommentTableViewCell {
    private func configureData() {
        guard let feedViewModel = self.feedViewModel else {
            return
        }
        self.captionLabel.text = feedViewModel.caption
        self.profileImageView.sd_setImage(with: feedViewModel.profileImageUrl, completed: nil)
        infoLabel.attributedText = feedViewModel.userInfoText
                
    }
}
