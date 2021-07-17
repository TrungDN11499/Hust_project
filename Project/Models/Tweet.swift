//
//  Tweet.swift
//  Project
//
//  Created by Be More on 10/14/20.
//

import Foundation

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
    
    var isReply: Bool {
        return self.replyingTo != nil
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
    
}
