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
import RxSwift
import Accelerate

protocol FeedsServiceProtocol {
    /// fetch all tweets for user
    /// - Parameters:
    ///   - user: input user
    ///   - completion: @escaping ([Tweet]) -> ()
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> Void)
    
    /// fetch  tweet for id
    /// - Parameters:
    ///   - tweetId: input id
    ///   - completion: @escaping (Tweet) -> ()
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> Void)
    
    /// fetch all tweets for user
    /// - Returns: `Observable<([Tweet], Error?)>`
    func fetchTweets() -> Observable<([Tweet], Error?)>
    
    /// like or unlike a tweet
    /// - Parameters:
    ///   - tweet: `Tweet`
    ///   - completion: `@escaping ((Error? , Int, DatabaseReference) -> Void)`
    func likeTweet(tweet: Tweet, completion: @escaping ((Error?, Int, DatabaseReference) -> Void))
    
    /// delete tweet
    /// - Parameters:
    ///   - tweet: `Tweet`
    ///   - completion: `@escaping ((Error? ,DatabaseReference) -> Void)`
    func deleteTweet(tweet: Tweet, completion: @escaping ((Error?, DatabaseReference) -> Void))
}

class FeedsService: FeedsServiceProtocol {
    func fetchTweets() -> Observable<([Tweet], Error?)> {
        var tweets = [Tweet]()
        
        let MAX_API_COUNTER = 2
        var finalStatus = true
        var fetchTweetError: Error?
        
        return Observable<([Tweet], Error?)>.create { observer  in
            var numberFinished = 0 {
                didSet {
                    if numberFinished == MAX_API_COUNTER {
                        if finalStatus {
                            observer.onNext((tweets, nil))
                        } else {
                            observer.onNext((tweets, fetchTweetError))
                        }
                    }
                }
            }

            // get following user tweets.
            self.fetchFollowingUserTweets { (success, followingUserTweets) in
                if success {
                    if let followingUserTweets = followingUserTweets {
                        tweets.append(contentsOf: followingUserTweets)
                    }
                    numberFinished += 1
                } else {
                    finalStatus = success
                    fetchTweetError = TriponusTweetsError.fetchFollowingUserTweetsError
                }
            }
            
            // get current user tweets.
            self.fetchUserTweets { (success, currentUserTweets) in
                if success {
                    if let currentUserTweets =  currentUserTweets {
                        tweets.append(contentsOf: currentUserTweets)
                    }
                    numberFinished += 1
                } else {
                    finalStatus = success
                    fetchTweetError = TriponusTweetsError.fetchUserTweetsError
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// fetch current user tweets.
    /// - Parameters:
    ///   - completion: @escaping (Bool, [Tweet]?) -> ()
    private func fetchUserTweets(completion: @escaping (Bool, [Tweet]?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_TWEETS.child(currentUid).observe(.value) { snapshot in
            var userTweets = [Tweet]()
            
            if snapshot.childrenCount == 0 {
                completion(true, nil)
            }
            
            for child in snapshot.children {
                if let snapshotChild = child as? DataSnapshot {
                    let tweetId = snapshotChild.key
                    self.fetchTweet(withTweetId: tweetId) { tweetsData in
                        self.checkIfUserLikeTweet(tweet: tweetsData) { didLike in
                            let likedTweet = tweetsData
                            likedTweet.didLike.value = didLike
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
    
    /// fetch following user tweets.
    /// - Parameters:
    ///   - completion: `@escaping (Bool, [Tweet]?) -> ()`
    private func fetchFollowingUserTweets(completion: @escaping (Bool, [Tweet]?) -> Void) {
        var followingCount = 0
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        REF_USER_FOLLOWING.child(currentUid).observe(.value) { flowwingSnapshot in
            
            if flowwingSnapshot.childrenCount == 0 {
                completion(true, nil)
            }
            
            var existChỉlds = flowwingSnapshot.childrenCount
            var nonExistChilds = 0
            for child in flowwingSnapshot.children {
                var followingTweets = [Tweet]()
                if let snapshotChild = child as? DataSnapshot {
                    let followedUid = snapshotChild.key
                    
                    REF_USER_TWEETS.child(followedUid).observe(.value) { tweetsSnapshot in
                        
                        if tweetsSnapshot.childrenCount == 0 {
                            nonExistChilds += 1
                            existChỉlds -= 1
                            if nonExistChilds == flowwingSnapshot.childrenCount {
                                completion(true, nil)
                            }
                        }
                        
                        for child in tweetsSnapshot.children {
                            if let snapshotChild = child as? DataSnapshot {
                                let tweetId = snapshotChild.key
                                self.fetchTweet(withTweetId: tweetId) { tweetsData in
    
                                    self.checkIfUserLikeTweet(tweet: tweetsData) { didLike in
                                        let likedTweet = tweetsData
                                        likedTweet.didLike.value = didLike
                                        followingTweets.append(likedTweet)
                                        if followingTweets.count == tweetsSnapshot.childrenCount {
                                            tweets.append(contentsOf: followingTweets)
                                            followingCount += 1
                                            if followingCount == existChỉlds {
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
    
    /// check tweet like of the current user
    /// - Parameters:
    ///   - tweet: Tweet
    ///   - completion: @escaping (Bool) -> ()
    /// - Returns: Void
    private func checkIfUserLikeTweet(tweet: Tweet, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_LIKES.child(uid).child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
            dLogDebug(snapshot.exists())
            completion(snapshot.exists())
        }
    }
    
    func fetchTweets(forUser user: User, completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        REF_USER_TWEETS.child(user.uid).observe(.childAdded) { (snapshot) in
            let tweetId = snapshot.key
            
            self.fetchTweet(withTweetId: tweetId) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    func fetchTweet(withTweetId tweetId: String, completion: @escaping (Tweet) -> Void) {
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
    
    func likeTweet(tweet: Tweet, completion: @escaping ((Error?, Int, DatabaseReference) -> Void)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if tweet.didLike.value ?? false {
            REF_USER_LIKES.child(uid).child(tweet.tweetId).removeValue { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).child(uid).removeValue { err, ref in
                    REF_TWEET_LIKES.child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
                        let numberOfLikes = snapshot.childrenCount
                        REF_TWEETS.child(tweet.tweetId).child("likes").setValue(numberOfLikes) { err, dataRef in
                            completion(err, Int(numberOfLikes), dataRef)
                        }
                    }
                    
                }
            }
        } else {
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetId: 1]) { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).updateChildValues([uid: 1]) { err, ref in
                    REF_TWEET_LIKES.child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
                        let numberOfLikes = snapshot.childrenCount
                        REF_TWEETS.child(tweet.tweetId).child("likes").setValue(numberOfLikes) { err, dataRef in
                            completion(err, Int(numberOfLikes), dataRef)
                        }
                    }
                }
            }
        }
        
    }
    
    func deleteTweet(tweet: Tweet, completion: @escaping ((Error?, DatabaseReference) -> Void)) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        REF_TWEET_LIKES.child(tweet.tweetId).removeValue  { error, dataReference in
            REF_TWEETS.child(tweet.tweetId).removeValue { error, dataReference in
                
                REF_USER_LIKES.observe(.childAdded) { snapshot in
                    REF_USER_LIKES.child(snapshot.key).child(tweet.tweetId).removeValue()
                }
                
                REF_USER_TWEETS.child(currentUserId).child(tweet.tweetId).removeValue(completionBlock: completion)
            }
        }
    }
    
}
