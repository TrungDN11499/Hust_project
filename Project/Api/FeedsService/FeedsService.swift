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
    func fetchTweet(completion: @escaping ([Tweet]) -> ())
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> ())
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> ())
}

class FeedsService: FeedsServiceProtocol {
    
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
        
        // get following user tweets.
        self.fetchFollowingUserTweets { (success, followingUserTweets) in
            if success {
                if let followingUserTweets = followingUserTweets {
                    tweets.append(contentsOf: followingUserTweets)
                    finishFollowingCount = success
                }
            } else {
                finalStatus = success
            }
        }
        
        // get current user tweets.
        self.fetchUserTweets { (success, currentUserTweets) in
            if success {
                if let currentUserTweets =  currentUserTweets {
                    tweets.append(contentsOf: currentUserTweets)
                    numberFinished += 1
                }
            } else {
                finalStatus = false
            }
        }
    }
    
    /// fetch current user tweets
    /// - Parameters:
    ///   - completion: @escaping (Bool, [Tweet]) -> ()
    /// - Returns: Void
    private func fetchUserTweets(completion: @escaping (Bool, [Tweet]?) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_TWEETS.child(currentUid).observe(.value) { snapshot in
            var userTweets = [Tweet]()
            for child in snapshot.children {
                if let snapshotChild = child as? DataSnapshot {
                    let tweetId = snapshotChild.key
                    self.fetchTweet(withTweetId: tweetId) { tweetsData in
                        self.checkIfUserLikeTweet(tweet: tweetsData) { didLike in
                            var likedTweet = tweetsData
                            likedTweet.didLike = didLike
                            userTweets.append(likedTweet)
                            if userTweets.count == snapshot.childrenCount {
                                completion(true, userTweets)
                            }
                        }
                    }
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    private func fetchFollowingUserTweets(completion: @escaping (Bool, [Tweet]?) -> ()) {
        var followingCount = 0
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
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
    
                                    self.checkIfUserLikeTweet(tweet: tweetsData) { didLike in
                                        var likedTweet = tweetsData
                                        likedTweet.didLike = didLike
                                        followingTweets.append(likedTweet)
                                        if followingTweets.count == tweetsSnapshot.childrenCount {
                                            tweets.append(contentsOf: followingTweets)
                                            followingCount += 1
                                            if followingCount == flowwingSnapshot.childrenCount {
                                                completion(true, tweets)
                                            }
                                        }
                                    }
                                }
                            } else {
                                completion(false, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkIfUserLikeTweet(tweet: Tweet, completion: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_LIKES.child(uid).child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
            dLogDebug(snapshot.exists())
            completion(snapshot.exists())
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
