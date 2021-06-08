//
//  CreateGroupParams.swift
//  Triponus
//
//  Created by Be More on 27/05/2021.
//

import Foundation

class CreateGroupParams {
    var groupName: String = ""
    var groupPrivacy: Int = 0
    
    init(privacy: Int, name: String) {
        self.groupPrivacy = privacy
        self.groupName = name
    }
}
