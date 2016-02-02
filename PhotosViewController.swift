//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Richard Reed on 2/1/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchRecentPhotos() {
            (PhotosResult) -> Void in
            
            switch PhotosResult {
            case let .Success(photos):
                print("Successfully found \(photos.count) recent photos.")
                
                if let firstPhoto = photos.first {
                    self.store.fetchImageForPhoto(firstPhoto, completion: { (ImageResult) -> Void in
                        switch ImageResult {
                        case let .Success(image):
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.imageView.image = image
                            }
                        case let .Failure(error):
                            print("Error downloading image: \(error)")
                        }
                    })
                }
                
            case let .Failure(error):
                print("Error fetching recent photos: \(error)")
            }
        }
    }
    
}
