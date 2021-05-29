//
//  SettingModel.swift
//  Triponus
//
//  Created by admin on 27/05/2021.
//

import Foundation

struct SettingModel {
    let objectImageString: String
    let objectLabelString: String
    
    init(objectImageString: String, objectLabelString: String) {
        self.objectImageString = objectImageString
        self.objectLabelString = objectLabelString
    }
}

class SettingObject {
    let setting = [
    SettingModel(objectImageString: "ic_edit", objectLabelString: "Edit Profile"),
    SettingModel(objectImageString: "ic_group", objectLabelString: "Groups"),
    SettingModel(objectImageString: "ic_logout", objectLabelString: "Logout")
    ]
}
