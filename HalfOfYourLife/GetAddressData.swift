//
//  GetAddressData.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 6. 12..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import Foundation
import CoreLocation

struct AddressData {
    var sidoName: String
    var sigunguName: String
}

class AddressModule {
    private let accessToken: String
    
    init?() {
        guard let token = AddressModule.getAccessToken() else {return nil}
        self.accessToken = token
    }
    
    class func getAccessToken() -> String? {
        let requestURL = "https://sgisapi.kostat.go.kr/OpenAPI3/auth/authentication.json?"
        if let path = Bundle.main.path(forResource: "data", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                if let key = dict["addrkey"] as? String, let id = dict["addrid"] as? String {
                    let fullURL = requestURL + "consumer_key=\(id)&consumer_secret=\(key)"
                    guard let jsonDict = requestJson(urlStr: fullURL),
                    let result = jsonDict["result"] as? [String:Any]
                        else {return nil}
                    return result["accessToken"] as? String
                }
            }
        }
        return nil
    }
    
    func getAddressData(coord: CLLocationCoordinate2D) -> AddressData? {
        let requestURL = "https://sgisapi.kostat.go.kr/OpenAPI3/addr/rgeocode.json?"
        guard let transcoord = changeCoordForm(coord: coord) else {return nil}
        let fullURL = requestURL + "accessToken=\(accessToken)&x_coor=\(transcoord.x)&y_coor=\(transcoord.y)"
        
        guard
        let dict = AddressModule.requestJson(urlStr: fullURL),
        let result = dict["result"] as? [[String:Any]],
        let firstResult = result.first,
        let sidoName = firstResult["sido_nm"] as? String,
        let sigunguName = firstResult["sgg_nm"] as? String
        else {return nil}
        return AddressData(sidoName: sidoName, sigunguName: sigunguName)
    }
    
    func changeCoordForm(coord: CLLocationCoordinate2D) -> (x: Double, y: Double)? {
        let srcCode = 4326
        let dstCode = 5179
        let requestURL = "https://sgisapi.kostat.go.kr/OpenAPI3/transformation/transcoord.json?"
        let fullURL = requestURL + "accessToken=\(accessToken)&src=\(srcCode)&dst=\(dstCode)&posX=\(coord.longitude)&posY=\(coord.latitude)"
        guard
        let dict = AddressModule.requestJson(urlStr: fullURL),
        let result = dict["result"] as? [String:Any],
        let x = result["posX"] as? Double,
        let y = result["posY"] as? Double
        else {
            return nil
        }
        return (x, y)
    }
    
    class func requestJson(urlStr: String) -> [String:Any]? {
        guard
        let url = URL(string: urlStr),
        let data = try? Data(contentsOf: url),
        let json = try? JSONSerialization.jsonObject(with: data),
        let dict = json as? [String:Any]
        else {return nil}
        return dict
    }
}
