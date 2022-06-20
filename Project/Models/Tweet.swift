//
//  Tweet.swift
//  Project
//
//  Created by Be More on 10/14/20.
//

import UIKit

class Tweet {
    let caption: String
    let tweetId: String
    var likes = Observable1<Int>()
    var comments = Observable1<Int>()
    var timestamp: Date!
    let retweets: Int
    var user: User!
    var didLike = Observable1<Bool>()
    var replyingTo: String?
    var images = [ImageParam]()
    
    var timestampString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: self.timestamp, to: now) ?? ""
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a • MM/dd/yyy"
        return formatter.string(from: self.timestamp)
    }
    
    var profileImageUrl: URL? {
        guard let imageUrl = URL(string: self.user.profileImageUrl) else { return nil }
        return imageUrl
    }
    
    var userInfoText: NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: "\(self.user.fullName)\n", attributes: [NSAttributedString.Key.font: UIFont.robotoBold(point: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: "@\(self.user.username.lowercased()) • \(self.timestampString)", attributes: [NSAttributedString.Key.font: UIFont.robotoRegular(point: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
    
    var hideSeeMore: Bool {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
    
        let cellPadding: CGFloat = 12
        let actionButtonSize: CGFloat = 25
        
        let textWidth = screenWidth - (actionButtonSize + cellPadding * 3)
        return !(self.caption.height(withConstrainedWidth: textWidth, font: UIFont.robotoRegular(point: 14)) > 200)
    }
    
    var retweetsAttributedString: NSAttributedString? {
        return self.attributeText(withValue: self.retweets, text: "Retweets")
    }
    
    var likessAttributedString: NSAttributedString? {
        return self.attributeText(withValue: self.likes.value ?? 0, text: "Likes")
    }
    
    var usernameText: String {
        return "@\(self.user.username)"
    }
    
    var shouldHideReplyLabel: Bool {
        return !self.isReply
    }

    var replyText: String? {
        guard let replyingTo = replyingTo else { return nil }
        return "→ replying to @\(replyingTo)"
    }
    
    var likeButtonTintColor: UIColor {
        return self.didLike.value ?? false ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage? {
        let imageName = self.didLike.value ?? false ? "ic_heart_filled" : "ic_heart"
        return UIImage(named: imageName)
    }
    
    
    var isReply: Bool {
        return self.replyingTo != nil
    }
    
    convenience init() {
        self.init(user: User(uid: "", dictionary: [:]), tweetId: "", dictionary: [:])
    }
    
    init(user: User, tweetId: String, dictionary: [String: Any]) {
        
        self.didLike.value = false
        
        self.tweetId = tweetId
        self.user = user
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
        
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes.value = dictionary["likes"] as? Int ?? 0
        self.comments.value = dictionary["comments"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        
        let imageDictionary = dictionary["images"] as? [[String :Any]]
        if let imageDictionary = imageDictionary {
            self.images = imageDictionary.map { ImageParam($0) }
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
    }
    
    private func attributeText(withValue value: Int, text: String) -> NSAttributedString {
        
        let attributeString = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                                         .foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
    
}
