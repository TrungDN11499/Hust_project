//
//  BindingTextField.swift
//  Project
//
//  Created by Be More on 10/11/20.
//

import UIKit

class BindingTextField: UITextField {
    
    private var completion: (String) -> () = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commondInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commondInit()
    }
    
    init(controlEvent: UIControl.Event) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addTarget(self, action: #selector(handleGesture(_:)), for: controlEvent)
    }
    
    private func commondInit() {
        self.addTarget(self, action: #selector(handleGesture(_:)), for: .editingChanged)
    }
    
    func bind(callBack: @escaping (String) -> ()) {
        self.completion = callBack
    }
    
    @objc private func handleGesture(_ sender: UITextField) {
        guard let text = sender.text else { return }
        dLogDebug(text)
        self.completion(text)
    }
}

