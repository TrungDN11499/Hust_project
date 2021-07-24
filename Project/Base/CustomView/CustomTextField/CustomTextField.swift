//
//  CustomTextField.swift
//  Triponus
//
//  Created by admin on 04/05/2021.
//

import UIKit
import RxSwift
import RxCocoa

class CustomTextField: UIView {
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customTextField: UITextField!
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "CustomTextField") else { return }
        view.frame = self.bounds
        self.addSubview(view)
        customTextField.attributedPlaceholder = NSAttributedString(string: "email",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    func bind(_ observer: AnyObserver<String>) {
        self.customTextField.rx.text.asObservable()
            .ignoreNil()
            .subscribe(observer)
            .disposed(by: disposeBag)
        
    }
}
