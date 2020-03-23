//
//  Extension+UIImageView.swift
//  JustChat
//
//  Created by Alexander Saprykin on 24.03.2020.
//  Copyright © 2020 Alexander Saprykin. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageUsingCache(by urlString: String) {
        let imageCache: NSCache<NSString, UIImage> = NSCache()
        guard let url = URL(string: urlString) else { return }
        
        if let cachedImage = imageCache.object(forKey: NSString(string: urlString)) {
            image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            if let downloadedImage = UIImage(data: data) {
                imageCache.setObject(downloadedImage, forKey: NSString(string: urlString))
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}
