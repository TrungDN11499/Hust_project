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
//            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))
            optionsButton.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(chatLogController?.handleOptionsSend)))
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "    Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.backgroundColor = .systemGray6
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 15
        return textField
    }()
    
//    let uploadImageView: UIImageView = {
//        let uploadImageView = UIImageView()
//        uploadImageView.isUserInteractionEnabled = true
//        uploadImageView.image = UIImage(named: "upload_image_icon")
//        uploadImageView.backgroundColor = .darkGray
//        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
//
//        return uploadImageView
//    }()
    
    let optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
//        addSubview(uploadImageView)
        addSubview(optionsButton)
        //x,y,w,h
//        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
//        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        uploadImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        
        optionsButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        optionsButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        optionsButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        optionsButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        optionsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        //what is handleSend?
        
        addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        
        addSubview(self.inputTextField)
        //x,y,w,h
//        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.leftAnchor.constraint(equalTo: optionsButton.rightAnchor, constant: 8).isActive = true

        self.inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220, alpha: 0)
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
