//
//  FeedsViewModel.swift
//  Project
//
//  Created by Be More on 28/03/2021.
//

import Foundation

class FeedsViewModel: ViewModelProtocol {
    
    struct Input {
        var fetchTweets: Observable<Any> = Observable()
    }
    
    struct Output {
        var fetchTweetsResult: Observable<[FeedViewModel]> = Observable()
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(feedsService: FeedsService) {
        self.input = Input()
        self.output = Output()
        
        self.input.fetchTweets.bind { observer, value in
            var values = [FeedViewModel]()
            feedsService.fetchTweet { [unowned self] tweets in
                self.sort(tweets: tweets).forEach { tweet in
                    let tweet = FeedViewModel(tweet: tweet)
                    values.append(tweet)
                }
                self.output.fetchTweetsResult.value = values
            }
        }
    }
}

// MARK: - Helper
extension FeedsViewModel {
    private func sort(tweets: [Tweet]) -> [Tweet] {
        
        guard !tweets.isEmpty else { return [Tweet]() }
        
        let newTweets = tweets.filter { (Int(Date().timeIntervalSince1970) - Int($0.timestamp.timeIntervalSince1970)) <= 24 * 60 * 60 }.sorted { $0.timestamp > $1.timestamp }
        
        let highInteractionTweets = tweets.filter { !((Int(Date().timeIntervalSince1970) - Int($0.timestamp.timeIntervalSince1970)) < 24 * 60 * 60) }.sorted { $0.timestamp > $1.timestamp }.sorted { $0.likes + $0.comments >  $1.likes + $1.comments }
        
        return newTweets + highInteractionTweets
    }
}
