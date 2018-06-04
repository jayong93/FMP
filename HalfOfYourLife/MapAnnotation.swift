//
//  MapAnnotation.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 6. 4..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let address: String
    var subtitle: String? {
        return self.address
    }
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
    }
}
