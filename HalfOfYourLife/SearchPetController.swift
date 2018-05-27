//
//  SearchPetController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

class CityListData: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let cities: [(String, String)]
    let owner: SearchPetController
    var list: UITextField!
    var selectedRow = 0
    
    init(cities: [(String, String)], list: UITextField!, owner: SearchPetController) {
        self.cities = cities
        self.list = list
        self.owner = owner
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cities[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        list.text = cities[row].0
        selectedRow = row
        
        if let towns = owner.getTownCodes(key: owner.apiKey, cityCode: cities[selectedRow].1) {
            if towns.count == 0 {
                owner.townListView.isEnabled = false
                owner.townListData = nil
                owner.townPicker.delegate = nil
            } else {
                owner.townListView.isEnabled = true
                owner.townListData = TownListData(towns: towns, townList: owner.townListView)
                owner.townPicker.delegate = owner.townListData!
            }
        }
    }
}

class TownListData: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let townList: UITextField!
    let towns: [(String, String)]
    var selectedRow = 0
    
    init(towns: [(String, String)], townList: UITextField!) {
        self.towns = towns
        self.townList = townList
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return towns.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return towns[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        townList.text = towns[row].0
        selectedRow = row
    }

}

class SearchPetController: UIViewController {
    @IBOutlet var cityListView: UITextField!
    @IBOutlet var townListView: UITextField!
    var apiKey = ""
    let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/"
    var cityListData: CityListData?
    var cityPicker = UIPickerView()
    var townListData: TownListData?
    var townPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let key = getAPIKey() {
            apiKey = key
            
            // 시군구 목록 가져오기
            if let cities = getCityCodes(key: apiKey) {
                cityListData = CityListData(cities: cities, list: cityListView, owner: self)
                cityPicker.delegate = self.cityListData
                cityListView.inputView = cityPicker
                cityListView.inputAccessoryView = createToolBar(select: #selector(SearchPetController.cityDonePressed))
                cityListView.text = cities[0].0
                
                if let towns = getTownCodes(key: apiKey, cityCode: cities[cityListData!.selectedRow].1) {
                    townListData = TownListData(towns: towns, townList: townListView)
                    townPicker.delegate = self.townListData!
                    townListView.inputView = townPicker
                    townListView.inputAccessoryView = createToolBar(select: #selector(SearchPetController.townDonePressed))
                    townListView.text = towns[0].0
                }
            }
        } else {
            // 검색 비활성화
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func getCityCodes(key: String) -> [(String, String)]? {
        let sidoURL = baseURL + "sido?serviceKey=\(key)"
        let xmlParser = XMLParser(contentsOf: URL(string: sidoURL)!)
        if let parser = xmlParser {
            let sidoParser = SidoParser()
            parser.delegate = sidoParser
            parser.parse()
            return sidoParser.sidoCodes
        }
        return nil
    }
    
    func getTownCodes(key: String, cityCode: String) -> [(String, String)]? {
        let sidoURL = baseURL + "sigungu?serviceKey=\(key)&upr_cd=\(cityCode)"
        let xmlParser = XMLParser(contentsOf: URL(string: sidoURL)!)
        if let parser = xmlParser {
            let sidoParser = SidoParser()
            parser.delegate = sidoParser
            parser.parse()
            return sidoParser.sidoCodes
        }
        return nil
    }
    
    func createToolBar(select: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: select)
        toolBar.items = [flexBar, doneBtn]
        return toolBar
    }
    
    @objc func townDonePressed() {
        townListView.resignFirstResponder()
    }
    
    @objc func cityDonePressed() {
        cityListView.resignFirstResponder()
    }
}
