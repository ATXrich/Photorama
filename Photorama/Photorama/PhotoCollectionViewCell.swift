//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Richard Reed on 5/11/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import UIKit


class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    
    // displays spinner if image not loaded
    func updateWithImage(image: UIImage?) {
        if let imagetoDisplay = image {
            spinner.stopAnimating()
            imageView.image = imagetoDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    // reset cell to spinning state when cell first created
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(nil)
    }
    
    
    // reset cell to spinning state when cell is getting resused
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(nil)
    }
    
}
