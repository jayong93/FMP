//
//  SearchPetController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit
import Foundation

class SearchPetController: UIViewController, CityBase {
    
    @IBOutlet var cityListView: UITextField!
    @IBOutlet var townListView: UITextField!
    @IBOutlet var searchStartDate: UITextField!
    @IBOutlet var searchEndDate: UITextField!
    @IBOutlet var searchBtn: UIButton!
    var apiKey = ""
    let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/"
    var cities: [City]!
    var cityData: CityListData?
    var cityPicker = UIPickerView()
    var townData: TownListData?
    var townPicker = UIPickerView()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let key = getAPIKey() {
            apiKey = key
            
            // 시군구 목록 가져오기
            cityData = CityListData(owner: self)
            cityPicker.delegate = self.cityData
            cityListView.inputView = cityPicker
            cityListView.inputAccessoryView = createToolBar(select: #selector(SearchPetController.cityDonePressed))
            cityListView.text = cities.first!.name
            
            townData = TownListData(owner: self, towns: cities.first!.towns)
            townPicker.delegate = self.townData!
            townListView.inputView = townPicker
            townListView.inputAccessoryView = createToolBar(select: #selector(SearchPetController.townDonePressed))
            townListView.text = cities.first!.towns.first!.name
            
            // 기간 선택
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
            searchStartDate.inputView = startDatePicker
            searchStartDate.inputAccessoryView = createToolBar(select: #selector(startDateDonePressed))
            searchStartDate.text = formatDate(date: startDatePicker.date)
            searchEndDate.inputView = endDatePicker
            searchEndDate.inputAccessoryView = createToolBar(select: #selector(endDateDonePressed))
            searchEndDate.text = formatDate(date: endDatePicker.date)
            startDatePicker.addTarget(self, action: #selector(SearchPetController.startDateChanged), for: UIControlEvents.valueChanged)
            endDatePicker.addTarget(self, action: #selector(SearchPetController.endDateChanged), for: UIControlEvents.valueChanged)
        } else {
            searchBtn.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchPets" {
            if let controller = segue.destination as? PetsController {
                controller.apiKey = apiKey
                controller.startDate = searchStartDate.text!
                controller.endDate = searchEndDate.text!
                controller.cityCode = cities[cityData!.selectedRow].code
                if let townData = townData {
                    controller.townCode = townData.towns[townData.selectedRow].code
                }
            }
        }
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
    
    func createToolBar(select: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: select)
        toolBar.items = [flexBar, doneBtn]
        return toolBar
    }
    
    func citySelected(index: Int) {
        townData?.towns = cities[index].towns
        cityListView.text = cities[index].name
        if let town = townData?.towns.first {
            townListView.isEnabled = true
            townListView.text = town.name
        } else {
            townListView.isEnabled = false
            townListView.text = nil
        }
    }
    
    func townSelected(index: Int) {
        if let townData = townData {
            townListView.text = townData.towns[index].name
        }
    }
    
    @objc func townDonePressed() {
        townListView.resignFirstResponder()
    }
    
    @objc func cityDonePressed() {
        cityListView.resignFirstResponder()
    }
    
    @objc func startDateDonePressed() {
        searchStartDate.resignFirstResponder()
    }
    
    @objc func endDateDonePressed() {
        searchEndDate.resignFirstResponder()
    }
    
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
    
    @objc func startDateChanged(sender: UIDatePicker) {
        searchStartDate.text = formatDate(date: sender.date)
    }
    
    @objc func endDateChanged(sender: UIDatePicker) {
        searchEndDate.text = formatDate(date: sender.date)
    }
}
