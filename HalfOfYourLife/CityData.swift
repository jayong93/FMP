//
//  CityData.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 28..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import Foundation

struct Town {
    var name: String
    var code: String
}

struct City {
    var name: String
    var code: String
    var towns: [Town]
}
