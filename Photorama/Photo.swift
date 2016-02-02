//
//  Photo.swift
//  Photorama
//
//  Created by Richard Reed on 2/1/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import UIKit

class Photo {
    
    let title: String
    let remoteURL: NSURL
    let photoID: String
    let dateTaken: NSDate
    var image: UIImage?
    
    init(title: String, photoID: String, remoteURL: NSURL, dateTaken: NSDate) {
        self.title = title
        self.photoID = photoID
        self.remoteURL = remoteURL
        self.dateTaken = dateTaken
    }
}
