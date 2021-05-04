//
//  LikeTweetParam.swift
//  Triponus
//
//  Created by Be More on 15/04/2021.
//

import Foundation

class LikeTweetParam {
    var feedViewModel: FeedViewModel
    var indexPath: IndexPath
    
    init(feedViewModel: FeedViewModel, indexPath: IndexPath) {
        self.feedViewModel = feedViewModel
        self.indexPath = indexPath
    }
}
