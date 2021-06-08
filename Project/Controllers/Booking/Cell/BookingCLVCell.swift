//
//  BookingCLVCell.swift
//  Triponus
//
//  Created by admin on 31/05/2021.
//

import UIKit

class BookingCLVCell: UICollectionViewCell {
    var booking : BookingModel? {
        didSet {
            guard let unrapped = booking else {return}
            bookingImageView.image = UIImage(named: unrapped.imageName)
        }
    }
    @IBOutlet weak var bookingImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
    }

}
