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
        guard let transcoord = changeCoordWGSToUTM(coord: coord) else {return nil}
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
    
    func getLocationFromAddress(address: String) -> CLLocationCoordinate2D? {
        let requsetURL = "https://sgisapi.kostat.go.kr/OpenAPI3/addr/geocode.json?"
        let fullURL = requsetURL + "accessToken=\(accessToken)&address=\(address)"
        
        guard
        let queryURL = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let dict = AddressModule.requestJson(urlStr: queryURL),
        let result = dict["result"] as? [String:Any],
        let resultData = result["resultdata"] as? [[String:Any]],
        let firstData = resultData.first,
        let xStr = firstData["x"] as? String,
        let yStr = firstData["y"] as? String,
        let x = Double(xStr),
        let y = Double(yStr),
        let coord = changeCoordUTMToWGS(x: x, y: y)
        else {return nil}
        
        return CLLocationCoordinate2D(latitude: coord.y, longitude: coord.x)
    }
    
    func changeCoordWGSToUTM(coord: CLLocationCoordinate2D) -> (x: Double, y: Double)? {
        let srcCode = 4326
        let dstCode = 5179
        return changeCoord(srcCode: srcCode, dstCode: dstCode, x: coord.longitude, y: coord.latitude)
    }
    
    func changeCoordUTMToWGS(x: Double, y: Double) -> (x:Double, y:Double)? {
        let srcCode = 5179
        let dstCode = 4326
        return changeCoord(srcCode: srcCode, dstCode: dstCode, x: x, y: y)
    }
    
    private func changeCoord(srcCode: Int, dstCode: Int, x: Double, y: Double) -> (x: Double, y:Double)? {
        let requestURL = "https://sgisapi.kostat.go.kr/OpenAPI3/transformation/transcoord.json?"
        let fullURL = requestURL + "accessToken=\(accessToken)&src=\(srcCode)&dst=\(dstCode)&posX=\(x)&posY=\(y)"
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

var addressModule: AddressModule! = AddressModule()
