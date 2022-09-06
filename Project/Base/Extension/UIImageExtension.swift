//
//  UIImageExtension.swift
//  Triponus
//
//  Created by Be More on 14/05/2021.
//

import UIKit
import Kingfisher

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func image(byTintColor color: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        color?.set()
        UIRectFill(rect)
        draw(at: CGPoint(x: 0, y: 0), blendMode: .destinationIn, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func getData(with maxsize: Int) -> Data? {
        let imageData = self.jpegData(compressionQuality: 1)
        var finalImageData = imageData
        if let imageSize = imageData?.count,
            imageSize > maxsize {
            let percentage = CGFloat(maxsize) / CGFloat(imageSize)
            let imageResized = self.resized(withPercentage: percentage)
            finalImageData = imageResized?.jpegData(compressionQuality: 1)
        }
        return finalImageData
    }

   // image with rounded corners
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
       let maxRadius = min(size.width, size.height) / 2
       let cornerRadius: CGFloat
       if let radius = radius, radius >= 0 && radius <= maxRadius {
           cornerRadius = radius
       } else {
           cornerRadius = maxRadius
       }
       UIGraphicsBeginImageContextWithOptions(size, false, scale)
       let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).addClip()
       draw(in: rect)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       return image
   }

    static func getImageFrom(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }
    
}

extension UIImageView {
    func setImageWith(imageUrl: String, placeHolder: UIImage? = nil) {
        let url = URL(string: imageUrl)
        let processor = DownsamplingImageProcessor(size: bounds.size)
        kf.setImage(with: url, placeholder: placeHolder,
                    options: [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale)
        ])
    }

    func setImage(with imageURL: String, completion: ((UIImage) -> Void)?) {
        guard let url = URL(string: imageURL) else {
            return
        }
        let resource = ImageResource(downloadURL: url)
        KingfisherManager.shared.retrieveImage(with: resource) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.image = result.image
                    completion?(result.image)
                }
            case .failure:
                break
            }
        }
    }
}
