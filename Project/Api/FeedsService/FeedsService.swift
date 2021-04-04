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
        
        let MAX_COUNTER = 2
        var finalStatus = true
        
        var numberFinished = 0 {
            didSet {
                if numberFinished == MAX_COUNTER {
                    if finalStatus {
                        completion(tweets)
                    }
                }
            }
        }
        
        var finishFollowingCount = false {
            didSet {
                if finishFollowingCount {
                    numberFinished += 1
                }
            }
        }
        
        var followingCount = 0
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // get following user tweet.
        REF_USER_FOLLOWING.child(currentUid).observe(.value) { flowwingSnapshot in
            for child in flowwingSnapshot.children {
                var followingTweets = [Tweet]()
                if let snapshotChild = child as? DataSnapshot {
                    let followedUid = snapshotChild.key
                    REF_USER_TWEETS.child(followedUid).observe(.value) { tweetsSnapshot in
                        for child in tweetsSnapshot.children {
                            if let snapshotChild = child as? DataSnapshot {
                                let tweetId = snapshotChild.key
                                self.fetchTweet(withTweetId: tweetId) { tweetsData in
                                    followingTweets.append(tweetsData)
                                    if followingTweets.count == tweetsSnapshot.childrenCount {
                                        tweets.append(contentsOf: followingTweets)
                                        followingCount += 1
                                        if followingCount == flowwingSnapshot.childrenCount {
                                            finishFollowingCount = true
                                        }
                                    }
                                }
                            } else {
                                finalStatus = false
                            }
                        }
                    }
                }
            }
        }
        
        self.fetchUserTweets { (success, currentUserTweets) in
            if success {
                tweets.append(contentsOf: currentUserTweets)
                numberFinished += 1
            } else {
                finalStatus = false
            }
        }
    }
    
    private func fetchUserTweets(completion: @escaping (Bool, [Tweet]) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_TWEETS.child(currentUid).observe(.value) { snapshot in
            var userTweets = [Tweet]()
            for child in snapshot.children {
                if let snapshotChild = child as? DataSnapshot {
                    let tweetId = snapshotChild.key
                    self.fetchTweet(withTweetId: tweetId) { tweetsData in
                        userTweets.append(tweetsData)
                        if userTweets.count == snapshot.childrenCount {
                            completion(true, userTweets)
                        }
                    }
                } else {
                    completion(false,[Tweet]())
                }
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
