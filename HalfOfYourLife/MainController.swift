//
//  MainController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 28..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

class MainController: UITabBarController {
    private let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/"
    private var apiKey: String?
    private var locaData: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let key = getAPIKey() {
            apiKey = key
            if let cityData = loadCityData() {
                for (name, code) in cityData {
                    if let townData = loadTownData(code){
                        let towns = townData.map({data in return Town(name: data.0, code: data.1)})
                        locaData.append(City(name: name, code: code, towns: towns.filter({ data in
                            return data.name != "용인시 기흥구" && data.name != "개별사업" && data.name != "가정보호"
                        })))
                    }
                }
            }
            
            if let views = viewControllers {
                let navs = views.map({view in return view as! UINavigationController})
                let hospitalView = navs[0].topViewController as! FindWithCityName
                let pharmacyView = navs[1].topViewController as! FindWithCityName
                let petView = navs[2].topViewController as! SearchPetController
                hospitalView.cities = locaData
                pharmacyView.cities = locaData
                petView.cities = locaData
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCityData() -> [(String, String)]? {
        let sidoURL = baseURL + "sido?serviceKey=\(apiKey!)"
        let xmlParser = XMLParser(contentsOf: URL(string: sidoURL)!)
        if let parser = xmlParser {
            let sidoParser = SidoParser()
            parser.delegate = sidoParser
            parser.parse()
            return sidoParser.sidoCodes
        }
        return nil
    }
    
    func loadTownData(_ cityCode: String) -> [(String, String)]? {
        let sidoURL = baseURL + "sigungu?serviceKey=\(apiKey!)&upr_cd=\(cityCode)"
        let xmlParser = XMLParser(contentsOf: URL(string: sidoURL)!)
        if let parser = xmlParser {
            let sidoParser = SidoParser()
            parser.delegate = sidoParser
            parser.parse()
            return sidoParser.sidoCodes
        }
        return nil
    }
    
    func getAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: "data", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                if let key = dict["spkey"] as? String {
                    return key
                }
            }
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
