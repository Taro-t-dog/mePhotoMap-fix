//
//  photoInfo.swift
//  mePhotoMap
//
//  Created by 瀬川太朗 on 2022/05/24.
//

import Foundation
import RealmSwift
import CoreLocation
import UIKit


class PhotoInfo: Object {
  
    @objc dynamic var latitude:CLLocationDegrees = 0.0
    @objc dynamic var longtitude:CLLocationDegrees = 0.0
    @objc dynamic var createdAt:String?
    @objc dynamic var imageFileName: String?
    
    
    
    
    
    
    
    

    
}
