//
//  UploadFeedParam.swift
//  Triponus
//
//  Created by Be More on 07/05/2021.
//

import UIKit

class UploadFeedParam {
    var images = [imageParam]()
    var caption = ""
}

class imageParam {
    var imageUrl = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    init(_ dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.width = dictionary["imageWidth"] as? CGFloat ?? 0
        self.height = dictionary["imageHeight"] as? CGFloat ?? 0
    }
    
    init(imageUrl: String, width: CGFloat, height: CGFloat) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
    
    func toDictionaty() -> [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary["imageUrl"] = self.imageUrl
        dictionary["imageWidth"] = self.width
        dictionary["imageHeight"] = self.height
        
        return dictionary
    }
}
