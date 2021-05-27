//
//  ChatInputContainerView.swift
//  Triponus
//
//  Created by Valerian on 07/05/2021.
//

import Foundation
import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {
    
    weak var chatLogController: ChatLogController? {
        didSet {
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            optionsButton.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handleOptionsSend)))
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 15
        return textField
    }()
    
    let optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(optionsButton)
        
        optionsButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        optionsButton.centerYAnchor.constraint(equalTo: centerYAnchor,constant: -10).isActive = true
        optionsButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        optionsButton.heightAnchor.constraint(equalTo: heightAnchor, constant: -20).isActive = true

        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        //what is handleSend?
        
        addSubview(sendButton)
        //x,y,w,h

        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor, constant: -20).isActive = true

        addSubview(self.containerView)
        
        self.containerView.leftAnchor.constraint(equalTo: optionsButton.rightAnchor, constant: 8).isActive = true
        self.containerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        self.containerView.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        containerView.addSubview(inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        self.inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
    
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 0)
//        separatorLineView.backgroundColor = .red
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
