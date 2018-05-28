//
//  FindWithCityName.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 26..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

class FindWithCityName: UIViewController {
    @IBOutlet var cityName: UITextField!
    @IBOutlet var searchButton: UIButton!
    var cities: [City]!
    var apiKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if false == checkCanSearch() {
            searchButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchHospital" {
            if let controller = segue.destination as? MedicalController {
                controller.key = apiKey
                controller.cityName = cityName.text
                controller.url = "https://openapi.gg.go.kr/Animalhosptl?pSize=50&Type=xml"
                controller.cellIdentifier = "HospitalCell"
            }
        }
        else if segue.identifier == "searchPharmacy" {
            if let controller = segue.destination as? MedicalController {
                controller.key = apiKey
                controller.cityName = cityName.text
                controller.url = "https://openapi.gg.go.kr/AnimalPharmacy?pSize=50&Type=xml"
                controller.cellIdentifier = "PharmacyCell"
            }
        }
    }

    func checkCanSearch() -> Bool {
        if let path = Bundle.main.path(forResource: "data", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) {
                if let key = dict["key"] as? String {
                    apiKey = key
                    return true
                }
            }
        }
        return false
    }
}
