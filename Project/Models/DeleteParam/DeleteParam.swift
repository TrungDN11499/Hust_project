//
//  DeleteParam.swift
//  Triponus
//
//  Created by Be More on 23/04/2021.
//

import Foundation

class DeleteParam {
    var tweet: Tweet
    var indexPath: IndexPath
    
    init(tweet: Tweet, at indexPath: IndexPath) {
        self.tweet = tweet
        self.indexPath = indexPath
    }
}
