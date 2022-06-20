//
//  FeedsViewModel.swift
//  Project
//
//  Created by Be More on 28/03/2021.
//

import Foundation
import RxSwift
import RxCocoa

class FeedsViewModel: ViewModelProtocol {
    
    struct Input {
        let fetchTweets: AnyObserver<Void>
        let likeTweet: AnyObserver<Void>
        let deleteTweet: AnyObserver<Void>
    }
    
    struct Output {
        let fetchTweetResultObservable: Observable<[Tweet]>
        let errorsObservable: Observable<Error>
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    let isLoading = BehaviorRelay(value: false)
    
    // MARK: - Private properties
    private let fetchTweetsSubject = PublishSubject<Void>()
    private let likeTweetSubject = PublishSubject<Void>()
    private let deleteTweetSubject = PublishSubject<Void>()
    private let fetchTweetResultSubject = PublishSubject<[Tweet]>()
    private let errorsSubject = PublishSubject<Error>()
    private let disposeBag = DisposeBag()
    
    init(feedsService: FeedsService) {
        self.input = Input(fetchTweets: fetchTweetsSubject.asObserver(),
                           likeTweet: likeTweetSubject.asObserver(),
                           deleteTweet: deleteTweetSubject.asObserver())
        self.output = Output(fetchTweetResultObservable: fetchTweetResultSubject.asObserver(),
                             errorsObservable: errorsSubject.asObserver())
        
        // fetch tweets
        self.fetchTweetsSubject.do(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.isLoading.accept(true)
        }).flatMapLatest { _ in
            return feedsService.fetchTweets()
        }.subscribe(onNext: { [weak self] result in
            guard let `self` = self else {return}
            if let error = result.1 {
                self.errorsSubject.onNext(error)
            } else {
                self.fetchTweetResultSubject.onNext(result.0)
            }
            self.isLoading.accept(false)
        }).disposed(by: self.disposeBag)

        // fetch tweets
//        self.input.fetchTweets.bind { observer, value in
//            var values = [FeedViewModel]()
//
//            feedsService.fetchTweet { [unowned self] tweets in
//                self.sort(tweets: tweets).forEach { tweet in
//                    let tweet = FeedViewModel(tweet)
//                    values.append(tweet)
//                }
//                self.output.fetchTweetsResult.value = values
//            }
//        }

        // like tweet
//        self.input.likeTweet.bind { observer, value  in
//            feedsService.likeTweet(tweet: value.feedViewModel.tweet) { [unowned self] error, numberOfLikes, reference in
//
//                self.viewModel(at: value.indexPath)?.tweet.likes.value = numberOfLikes
//                self.viewModel(at: value.indexPath)?.tweet.didLike.value = !(value.feedViewModel.tweet.didLike.value ?? false)
//
//                // only upload notification when user like
//                guard let didLike = value.feedViewModel.tweet.didLike.value, didLike else { return }
//                NotificationService.shared.uploadNotification(.like, tweet: value.feedViewModel.tweet)
//            }
//        }

        // delete tweet
//        self.input.deleteTweet.bind { observer, value in
//            feedsService.deleteTweet(tweet: value.tweet) { [unowned self] error, ref in
//
//                if error == nil {
//                    self.output.fetchTweetsResult.value?.remove(at: value.indexPath.item)
//                }
//
//            }
//        }
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
        return nil
    }
}
