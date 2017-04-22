//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Joseph Kim on 4/16/17.
//  Copyright © 2017 Joseph Kim. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, err) in
            guard let this = self, let imageData = data else { return }
            
            if let err = err {
                print("Failed to fetch post image:", err)
                return
            }
            
            if url.absoluteString != this.lastURLUsedToLoadImage {
                return
            }

            let photoImage = UIImage(data: imageData)
            
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                this.image = photoImage
            }
            
        }.resume()
    }
}
