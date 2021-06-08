//
//  CreateGroupViewModel.swift
//  Triponus
//
//  Created by Be More on 27/05/2021.
//

import UIKit

class CreateGroupViewModel: ViewModelProtocol {
    struct Input {
        var createGroup = Observable<CreateGroupParams>()
    }
    
    struct Output {
        var createGroupResult = Observable<CreateGroupParams>()
    }
    
    let input: Input
    let output: Output
    
    init() {
        self.input = Input()
        self.output = Output()
        
        self.input.createGroup.bind { observable, value in
            self.output.createGroupResult.value = value
        }
    }
    
    
    func validateInput(name: String, privacy: String) -> Bool {
        if !String.isNilOrEmpty(name) && !String.isNilOrEmpty(privacy) {
            return true
        } else {
            return false
        }
    }
}
