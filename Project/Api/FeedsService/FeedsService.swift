//
//  FeedsService.swift
//  Project
//
//  Created by Be More on 28/03/2021.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol FeedsServiceProtocol {
    /// completion with data base reference
    typealias Completion = (Error? ,DatabaseReference) -> ()
    func fetchTweet(completion: @escaping ([Tweet]) -> ())
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> ())
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> ())
}

class FeedsService: FeedsServiceProtocol {
    typealias Completion = (Error? ,DatabaseReference) -> ()
    
    func fetchTweet(completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        REF_USER_FOLLOWING.child(currentUid).observe(.childAdded) { snapshot in
            let followedUid = snapshot.key
            
            REF_USER_TWEETS.child(followedUid).observe(.childAdded) { snapshot in
                let tweetId = snapshot.key
                self.fetchTweet(withTweetId: tweetId) { tweetsData in
                    tweets.append(tweetsData)
                    completion(tweets)
                }
            }
        }
        
        REF_USER_TWEETS.child(currentUid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            self.fetchTweet(withTweetId: tweetId) { tweetsData in
                tweets.append(tweetsData)
                completion(tweets)
            }
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> ()) {
        REF_TWEETS.child(tweetId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetId = snapshot.key
            
            UserService.shared.fetchUser(userId: uid) { user in
                guard let user = user else { return }
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
}
