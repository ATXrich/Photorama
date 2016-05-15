//
//  ImageStore.swift
//  Photorama
//
//  Created by Richard Reed on 5/4/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import UIKit

class ImageStore {
    
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
        
        // Create full URL for image
        let imageURL = imageURLForKey(key)
        
        
        // Turn image into JPEG data
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            // Write it to full URL
            data.writeToURL(imageURL, atomically: true)
        }
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = cache.objectForKey(key) as? UIImage {
            return existingImage
        }
        
        let imageURL = imageURLForKey(key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) else {
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObjectForKey(key)
        
        // Remove image from filesystem
        let imageURL = imageURLForKey(key)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageURL)
        } catch {
            print("Error removing the image from disk: \(error)")
        
        }
       
    
    }
    
    func imageURLForKey(key: String) -> NSURL {
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectory.first!
        
        return documentDirectory.URLByAppendingPathComponent(key)
    }
}
