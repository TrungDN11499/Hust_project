//
//  UploadFeedParam.swift
//  Triponus
//
//  Created by Be More on 07/05/2021.
//

import UIKit

class UploadFeedParam {
    var images = [ImageParam]()
    var caption = ""
    
    init(caption: String, images: [ImageParam]? = nil) {
        self.caption = caption
        if let images = images {
            self.images = images
        }
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary["caption"] = self.caption
        if !self.images.isEmpty {
            dictionary["images"] = self.images.map { $0.toDictionaty() }
        }
        return dictionary
    }
}

class ImageParam {
    var imageUrl = ""
    var image: UIImage = UIImage()
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
    
    init(image: UIImage) {
        self.image = image
        self.width = image.size.width
        self.height = image.size.height
    }
    
    func toDictionaty() -> [String: Any] {
        var dictionary = [String: Any]()
        
        dictionary["imageUrl"] = self.imageUrl
        dictionary["imageWidth"] = self.width
        dictionary["imageHeight"] = self.height
        
        return dictionary
    }
}
