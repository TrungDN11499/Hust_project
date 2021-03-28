//
//  FeedsViewModel.swift
//  Project
//
//  Created by Be More on 28/03/2021.
//

import Foundation

class FeedsViewModel: ViewModelProtocol {
    struct Input {
       
    }
    
    struct Output {
       
    }
    
    // MARK: - Public properties
    let input: Input
    let output: Output
    
    init(feedsService: FeedsService) {
        self.input = Input()
        self.output = Output()
    }
}
