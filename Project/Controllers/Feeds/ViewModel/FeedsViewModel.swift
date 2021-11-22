//
//  FeedsViewModel.swift
//  Project
//
//  Created by Be More on 28/03/2021.
//

import Foundation

class FeedsViewModel: ViewModelProtocol {
    
    struct Input {
        var fetchTweets: Observable1<Any> = Observable1()
        var likeTweet: Observable1<LikeTweetParam> = Observable1()
        var deleteTweet: Observable1<DeleteParam> = Observable1()
    }
    
    struct Output {
        var fetchTweetsResult: Observable1<[FeedViewModel]> = Observable1()
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(feedsService: FeedsService) {
        self.input = Input()
        self.output = Output()

        // fetch tweets
        self.input.fetchTweets.bind { observer, value in
            var values = [FeedViewModel]()
            feedsService.fetchTweet { [unowned self] tweets in
                self.sort(tweets: tweets).forEach { tweet in
                    let tweet = FeedViewModel(tweet)
                    values.append(tweet)
                }
                self.output.fetchTweetsResult.value = values
            }
        }

        // like tweet
        self.input.likeTweet.bind { observer, value  in
            feedsService.likeTweet(tweet: value.feedViewModel.tweet) { [unowned self] error, numberOfLikes, reference in

                self.viewModel(at: value.indexPath)?.tweet.likes.value = numberOfLikes
                self.viewModel(at: value.indexPath)?.tweet.didLike.value = !(value.feedViewModel.tweet.didLike.value ?? false)
        
                // only upload notification when user like
                guard let didLike = value.feedViewModel.tweet.didLike.value, didLike else { return }
                NotificationService.shared.uploadNotification(.like, tweet: value.feedViewModel.tweet)
            }
        }

        // delete tweet
        self.input.deleteTweet.bind { observer, value in
            feedsService.deleteTweet(tweet: value.tweet) { [unowned self] error, ref in
                
                if error == nil {
                    self.output.fetchTweetsResult.value?.remove(at: value.indexPath.item)
                }
                
            }
        }
    }
}

// MARK: - Helper
extension FeedsViewModel {
    private func sort(tweets: [Tweet]) -> [Tweet] {
        
        guard !tweets.isEmpty else { return [Tweet]() }
        
        let newTweets = tweets.filter { (Int(Date().timeIntervalSince1970) - Int($0.timestamp.timeIntervalSince1970)) <= 24 * 60 * 60 }.sorted { $0.timestamp > $1.timestamp }
        
        let highInteractionTweets = tweets.filter { !((Int(Date().timeIntervalSince1970) - Int($0.timestamp.timeIntervalSince1970)) < 24 * 60 * 60) }.sorted { $0.timestamp > $1.timestamp }.sorted { lhs, rhs in
            let lhsLikes = lhs.likes.value ?? 0
            let lhsComments = lhs.comments.value ?? 0
            
            let rhsLikes = rhs.likes.value ?? 0
            let rhsComments = rhs.comments.value ?? 0
            
            return lhsLikes + lhsComments > rhsLikes + rhsComments
        }
        
        
        
//        $0.likes.value ?? 0 + $0.comments.value >  $1.likes.value ?? 0 + $1.comments
        
        return newTweets + highInteractionTweets
    }
    
    func viewModel(at index: IndexPath) -> FeedViewModel? {
        return self.output.fetchTweetsResult.value?[index.item]
    }
}
