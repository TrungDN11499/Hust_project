//
//  BindingButton.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import UIKit

class BindingButton: UIButton {
    
    private var completion: (UIButton) -> () = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commontInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commontInit()
    }
    
    init(controlEvent: UIControl.Event) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addTarget(self, action: #selector(handleGesture(_:)), for: controlEvent)
    }
    
    func bind(callBack: @escaping (UIButton) -> ()) {
        self.completion = callBack
    }
    
    private func commontInit() {
        self.addTarget(self, action: #selector(handleGesture(_:)), for: .touchUpInside)
    }
    
    @objc private func handleGesture(_ sender: UIButton) {
        self.completion(sender)
    }
}
