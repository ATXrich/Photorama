//
//  Photo.swift
//  Photorama
//
//  Created by Richard Reed on 5/14/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {
    
    var image: UIImage?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        // Give the properties their initial values
        title = ""
        photoID = ""
        remoteURL = NSURL()
        photoKey = NSUUID().UUIDString
        dateTaken = NSDate()
    }

}
