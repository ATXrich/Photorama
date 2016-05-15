//
//  PhotoStore.swift
//  Photorama
//
//  Created by Richard Reed on 5/10/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//
// PhotoStore responsible for initiating web service requests

import UIKit
import CoreData


enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}


class PhotoStore {
    
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    let imageStore = ImageStore()
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        let url = FlickrAPI.recentPhotosURL()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            var result = self.processRecentPhotos(data: data, error: error)
            
            if case let .Success(photos) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performBlockAndWait({ 
                    try! mainQueueContext.obtainPermanentIDsForObjects(photos)
                })
                let objectIDs = photos.map{$0.objectID}
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotos(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return .Failure(error!)
        }
        
        return FlickrAPI.photosFromJSONData(jsonData, inContext: self.coreDataStack.mainQueueContext)
    }
    
    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        
        let photoKey = photo.photoKey
        
        // return image if already downloaded
        if let image = imageStore.imageForKey(photoKey) {
            photo.image = image
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let request = NSURLRequest(URL: photoURL)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }
            completion(result)
        }
        task.resume()
    }
    
    func processImageRequest(data data: NSData?, error: NSError?) -> ImageResult {
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                
                // Couldn't create an iamge
                if data == nil {
                    return .Failure(error!)
                } else {
                    return .Failure(PhotoError.ImageCreationError)
                }
        }
        return .Success(image)
    }
    
    // fetch photos from MainQueueContext
    func fetchMainQueuePhotos(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait { 
            do {
                mainQueuePhotos = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Photo]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        guard let photos = mainQueuePhotos else {
            throw fetchRequestError!
        }
        return photos
        
    }
    
    
}
