//
//  PhotoInfoAnnotation.swift
//  mePhotoMap
//
//  Created by 瀬川太朗 on 2022/06/02.
//

import Foundation
import MapKit
import CoreLocation

class PhotoInfoAnnotation:MKPointAnnotation {
    
   
    var photoInfo : PhotoInfo
    
    init(photoInfo:PhotoInfo) {
        self.photoInfo = photoInfo
         
        
    }
    
    
}
