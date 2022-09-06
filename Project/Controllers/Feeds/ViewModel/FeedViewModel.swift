//
//  FeedViewModel.swift
//  Project
//
//  Created by Be More on 30/03/2021.
//

import UIKit
import RxSwift

class FeedViewModel: ViewModelProtocol {
    
    // MARK: - ViewModelProtocol
    struct Input {
        let tweet: AnyObserver<Tweet>
    }

    struct Output {
        let tweetObservable: Observable<Tweet>
    }
    
    private let tweetSubject = PublishSubject<Tweet>()
    private let tweetResultSubject = PublishSubject<Tweet>()
    private let disposeBag = DisposeBag()

    let input: Input
    let output: Output

    // MARK: - Initializers
    init(_ tweet: Tweet) {
        self.input = Input(tweet: self.tweetSubject.asObserver())
        self.output = Output(tweetObservable: self.tweetResultSubject)
        self.tweet = tweet
        self.tweetSubject.subscribe(onNext: { [weak self] tweet in
            guard let `self` = self else { return }
            self.tweetResultSubject.onNext(tweet)
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - Properties
    private var user: User {
        guard let user = gUser else { return User(uid: "", dictionary: [:]) }
        return user
    }
    
    var tweet: Tweet!
        
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? ""
    }
    
    var headerTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a • MM/dd/yyy"
        return formatter.string(from: tweet.timestamp)
    }
    
    var profileImageUrl: URL? {
        guard let imageUrl = URL(string: tweet.user.profileImageUrl) else { return nil }
        return imageUrl
    }
    
    var userInfoText: NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: "\(self.user.fullName)\n", attributes: [NSAttributedString.Key.font: UIFont.robotoBold(point: 14), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: "@\(self.user.username.lowercased()) • \(self.timestamp)", attributes: [NSAttributedString.Key.font: UIFont.robotoRegular(point: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
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
        return self.attributeText(withValue: tweet.retweets, text: "Retweets")
    }
    
    var likessAttributedString: NSAttributedString? {
        return self.attributeText(withValue: tweet.likes.value ?? 0, text: "Likes")
    }
    
    var usernameText: String {
        return "@\(self.user.username)"
    }
    
    var caption: String {
        return tweet.caption
    }
    
    var likes: String {
        return self.tweet.likes.value ?? 0 != 0 ? String(self.tweet.likes.value ?? 0) : ""
    }
    
    var comments: String {
        return self.tweet.comments.value ?? 0 != 0 ? String(self.tweet.comments.value ?? 0) : ""
    }
    
    var shouldHideReplyLabel: Bool {
        return !tweet.isReply
    }

    var replyText: String? {
        guard let replyingTo = tweet.replyingTo else { return nil }
        return "→ replying to @\(replyingTo)"
    }
    
    var likeButtonTintColor: UIColor {
        return tweet.didLike.value ?? false ? .red : .lightGray
    }
    
    var likeButtonImage: UIImage? {
        let imageName = tweet.didLike.value ?? false ? "ic_heart_filled" : "ic_heart"
        return UIImage(named: imageName)
    }
    
    func likeButtonTintColor(_ didLike: Bool) -> UIColor {
        return didLike ? .red : .lightGray
    }
    
    func likeButtonImage(_ didLike: Bool) -> UIImage? {
        let imageName =  didLike ? "ic_heart_filled" : "ic_heart"
        return UIImage(named: imageName)
    }
    
}

// MARK: - Helpers
extension FeedViewModel {
    private func attributeText(withValue value: Int, text: String) -> NSAttributedString {
        
        let attributeString = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14),
                                                                                         .foregroundColor: UIColor.black])
        
        attributeString.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        
        return attributeString
    }
}
