//
//  FeedViewModel.swift
//  Project
//
//  Created by Be More on 30/03/2021.
//

import Foundation

class FeedViewModel: ViewModelProtocol {
    
    struct Input {
        var tweet: Observable<Tweet> = Observable()
    }
    
    struct Output  {
        var FeedViewModel: Observable<FeedViewModel> = Observable()
    }
    
    let input: Input
    let output: Output
    
    init(tweet: Tweet) {
        self.input = Input()
        self.output = Output()
        
        self.input.tweet.value = tweet
        self.output.FeedViewModel.value = self
    }
}
