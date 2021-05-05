//
//  CustomTextField.swift
//  Triponus
//
//  Created by admin on 04/05/2021.
//

import UIKit

class CustomTextField: UIView {

    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customTextField: BindingTextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "CustomTextField") else {return}
        view.frame = self.bounds
        self.addSubview(view)
    }
}
