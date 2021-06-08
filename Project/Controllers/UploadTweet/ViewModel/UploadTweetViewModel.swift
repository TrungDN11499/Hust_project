//
//  UploadTweetViewModel.swift
//  Project
//
//  Created by Be More on 10/18/20.
//

import UIKit

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}


class UploadTweetViewModel: ViewModelProtocol {
    struct Input {
       
    }
    
    struct Output {
      
    }
    
    // MARK: - Public properties
    let input: Input = Input()
    let output: Output = Output()
    
    let actionButtonText: String
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var reply: String?
    
    var user: User
    var config: UploadTweetConfiguration = .tweet
    
    var userInfoText: NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: "\(self.user.fullName)\n", attributes: [NSAttributedString.Key.font: UIFont.robotoBold(point: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: "@\(self.user.username.lowercased())", attributes: [NSAttributedString.Key.font: UIFont.robotoRegular(point: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
    
    init(_ config: UploadTweetConfiguration, user: User) {
        self.config = config
        self.user = user
        switch config {
        case .tweet:
            self.actionButtonText = "Tweet"
            self.placeholderText = "What's happening"
            self.shouldShowReplyLabel = false
        case .reply(let tweet):
            self.actionButtonText = "Reply"
            self.placeholderText = "Tweet your reply"
            self.shouldShowReplyLabel = true
            self.reply = "reply to @\(tweet.user.username)"
        }
    }
}
