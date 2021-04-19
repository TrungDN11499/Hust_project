//
//  FeedViewModel.swift
//  Project
//
//  Created by Be More on 30/03/2021.
//

import UIKit

class FeedViewModel: ViewModelProtocol {
    
    // MARK: - ViewModelProtocol
    struct Input {
        fileprivate var tweet: Observable<Tweet> = Observable()
    }
    
    struct Output  {
        
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Initializers
    init(_ tweet: Tweet) {
        self.input = Input()
        self.output = Output()
        
        self.input.tweet.value = tweet
    }
    
    // MARK: - Properties
    private var user: User {
        guard let tweet = self.input.tweet.value else {
            return User(uid: "", dictionary: ["": ""])
        }
        return tweet.user
    }
    
    var tweet: Tweet {
        get {
            guard let tweet = self.input.tweet.value else {
                return Tweet(user: self.user, tweetId: "", dictionary: ["": ""])
            }
            return tweet
        } set {
            self.input.tweet.value = newValue
        }
    }
        
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? ""
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a • MM/dd/yyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var profileImageUrl: URL? {
        guard let imageUrl = URL(string: tweet.user.profileImageUrl) else { return nil }
        return imageUrl
    }
    
    var userInfoText: NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: self.user.fullName, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: " @\(self.user.username.lowercased()) • \(self.timestamp)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
    
    var retweetsAttributedString: NSAttributedString? {
        return self.attributeText(withValue: tweet.retweets, text: "Retweets")
    }
    
    var likessAttributedString: NSAttributedString? {
        return self.attributeText(withValue: tweet.likes, text: "Likes")
    }
    
    var usernameText: String {
        return "@\(self.user.username)"
    }
    
    var caption: String {
        return tweet.caption
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }

    var replyText: String? {
        guard let replyingTo = tweet.replyingTo else { return nil }
        return "→ replying to @\(replyingTo)"
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage? {
        let imageName = tweet.didLike ? "like_filled" : "like"
        return UIImage(named: imageName)
    }
    
}

// MARK: - Helpers
extension FeedViewModel {
    private func attributeText(withValue value: Int, text: String) -> NSAttributedString {
        
        let attributeString = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                                         .foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
}
