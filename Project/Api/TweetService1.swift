//
//  TweetService.swift
//  Project
//
//  Created by Be More on 10/14/20.
//

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct TweetService1 {
    
    typealias Completion = (Error? ,DatabaseReference) -> Void
    
    static let shared = TweetService1()
    
    func upload(caption: String, images: [UIImage], type: UploadTweetConfiguration, completion: @escaping (Error? ,String, Int ,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = ["uid": uid,
                     "timestamp": Int(NSDate().timeIntervalSince1970),
                     "likes": 0,
                     "comments": 0,
                     "retweets": 0] as [String: Any]
        
        switch type {
        case .tweet:
            if !images.isEmpty {
                guard let imageData = images[0].jpegData(compressionQuality: 0.1) else { return }
                
                let imageWidth = images[0].size.width
                let imageHeight = images[0].size.height
                let fileName = NSUUID().uuidString
                let storagre = STORAGE_FEED_IMAMGES.child(fileName)
                let upload = storagre.putData(imageData)
                
                upload.observe(.progress) { snapshot in
                    
                    let percentComplete = (Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)) * 100.0
                    
                    print(percentComplete)
                }
                
                upload.observe(.success) { snapshot in
                    storagre.downloadURL { (url, error) in
                        
                        guard let imageUrl = url?.absoluteString else { return }
                        let imageParam = ImageParam(imageUrl: imageUrl, width: imageWidth, height: imageHeight)
                        let paramData = UploadFeedParam(caption: caption, images: [imageParam])
                        for (key, value) in paramData.toDictionary() {
                            values[key] = value
                        }
                        self.uploadTweet(with: values, completion: completion)
                    }
                }

                // Errors only occur in the "Failure" case
                upload.observe(.failure) { snapshot in
                    completion(snapshot.error, "", 0, DatabaseReference())
                }
            } else {
                values["caption"] = caption
                self.uploadTweet(with: values, completion: completion)
            }
        case .reply(let tweet):
            values["caption"] = caption
            values["replyingTo"] = tweet.user.username
            REF_TWEET_REPLIES.child(tweet.tweetId).childByAutoId().updateChildValues(values) { (err, ref) in
                guard let replyId = ref.key else { return }
                REF_USER_REPLIES.child(uid).updateChildValues([tweet.tweetId: replyId]) { (error, ref) in
                    REF_TWEET_REPLIES.child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
                        REF_TWEETS.child(tweet.tweetId).child("comments").setValue(snapshot.childrenCount) { err, dataRef in
                            completion(error, replyId, Int(snapshot.childrenCount), ref)
                        }
                    }
                }
            }
            
        }
    }
    
    private func uploadTweet(with dictionary: [String: Any], completion: @escaping (Error? ,String, Int ,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_TWEETS.childByAutoId().updateChildValues(dictionary) { (error, ref) in
            guard let tweetId = ref.key else { return }
            REF_USER_TWEETS.child(uid).updateChildValues([tweetId: 1]) { (error, ref) in
                completion(error, tweetId, 0, ref)
            }
        }
    }
    
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
        REF_USER_TWEETS.child(user.uid).observe(.value) { (snapshot) in
            
            guard snapshot.exists() else {
                completion(tweets)
                return
            }
            for child in snapshot.children {
                if let snapshotChild = child as? DataSnapshot {
                    let tweetId = snapshotChild.key
                    self.fetchTweet(withTweetId: tweetId) { tweet in
                        TweetService1.shared.checkIfUserLikeTweet(tweet: tweet) { didLike in
                            if didLike {
                                tweet.didLike.value = true
                            }
                            tweets.append(tweet)
                            completion(tweets)
                        }
                        
                    }
                }
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
    
    func fetchReply(forUser user: User, completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        REF_USER_REPLIES.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            REF_TWEET_REPLIES.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                
                let replyId = snapshot.key
                
                UserService.shared.fetchUser(userId: uid) { user in
                    guard let user = user else { return }
                    let tweet = Tweet(user: user, tweetId: replyId, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    
    func fetchReply(forTweet tweet: Tweet, completion: @escaping ([Tweet]) -> () ) {
        var tweets = [Tweet]()
        
        REF_TWEET_REPLIES.child(tweet.tweetId).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetId = snapshot.key
            UserService.shared.fetchUser(userId: uid) { user in
                guard let user = user else { return }
                let tweet = Tweet(user: user, tweetId: tweetId, dictionary: dictionary)
                tweets.append(tweet)
                tweets.sort { $0.timestamp > $1.timestamp }
                completion(tweets)
            }
        }
    }
    
    func fetchLike(forUser user: User, completion: @escaping([Tweet]) -> ()) {
        var tweets = [Tweet]()
        REF_USER_LIKES.child(user.uid).observe(.childAdded) { snapshot in
            self.fetchTweet(withTweetId: snapshot.key) { tweet in
                let likedTweet = tweet
                likedTweet.didLike.value = true
                tweets.append(likedTweet)
                completion(tweets)
            }
        }
    }
    
    func likeTweet(tweet: Tweet, completion: @escaping (Completion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let likes = tweet.didLike.value ?? false ? ((tweet.likes.value ?? 0 - 1) < 0 ? 0 : (tweet.likes.value ?? 0 - 1)) : tweet.likes.value ?? 0 + 1
        REF_TWEETS.child(tweet.tweetId).child("likes").setValue(likes)
        
        if tweet.didLike.value ?? false {
            REF_USER_LIKES.child(uid).child(tweet.tweetId).removeValue { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).child(uid).removeValue(completionBlock: completion)
            }
        } else {
            REF_USER_LIKES.child(uid).updateChildValues([tweet.tweetId: 1]) { (err, ref) in
                REF_TWEET_LIKES.child(tweet.tweetId).updateChildValues([uid: 1], withCompletionBlock: completion)
            }
        }
    }
    
    func checkIfUserLikeTweet(tweet: Tweet, completion: @escaping (Bool) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_LIKES.child(uid).child(tweet.tweetId).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func deleteTweet(tweet: Tweet, completion: @escaping Completion) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        REF_TWEET_LIKES.child(tweet.tweetId).removeValue  { error, dataReference in
            REF_TWEETS.child(tweet.tweetId).removeValue { error, dataReference in
                REF_USER_LIKES.child(currentUserId).child(tweet.tweetId).removeValue { error, dataReference in
                    REF_USER_TWEETS.child(currentUserId).child(tweet.tweetId).removeValue(completionBlock: completion)
                }
            }
        }
    }
    
}
