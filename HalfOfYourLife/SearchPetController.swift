//
//  SearchPetController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit
import Foundation

class CityListData: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let owner: SearchPetController
    var selectedRow = 0
    
    init(owner: SearchPetController) {
        self.owner = owner
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return owner.cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return owner.cities[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        owner.citySelected(index: selectedRow)
    }
}

class TownListData: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let owner: SearchPetController
    var towns: [Town]
    var selectedRow = 0
    
    init(owner: SearchPetController, towns: [Town]) {
        self.owner = owner
        self.towns = towns
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return towns.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return towns[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
        owner.townSelected(index: selectedRow)
    }

}

class SearchPetController: UIViewController {
    @IBOutlet var cityListView: UITextField!
    @IBOutlet var townListView: UITextField!
    @IBOutlet var searchStartDate: UITextField!
    @IBOutlet var searchEndDate: UITextField!
    @IBOutlet var searchBtn: UIButton!
    var apiKey = ""
    let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/"
    var cities: [City]!
    var cityListData: CityListData?
    var cityPicker = UIPickerView()
    var townListData: TownListData?
    var townPicker = UIPickerView()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let key = getAPIKey() {
            apiKey = key
            
            // 시군구 목록 가져오기
            cityListData = CityListData(owner: self)
            cityPicker.delegate = self.cityListData
            cityListView.inputView = cityPicker
            cityListView.inputAccessoryView = createToolBar(select: #selector(SearchPetController.cityDonePressed))
            cityListView.text = cities.first!.name
            
            townListData = TownListData(owner: self, towns: cities.first!.towns)
            townPicker.delegate = self.townListData!
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
                controller.cityCode = cities[cityListData!.selectedRow].code
                if let townData = townListData {
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
        townListData?.towns = cities[index].towns
        cityListView.text = cities[index].name
        if let town = townListData?.towns.first {
            townListView.isEnabled = true
            townListView.text = town.name
        } else {
            townListView.isEnabled = false
            townListView.text = nil
        }
    }
    
    func townSelected(index: Int) {
        if let townData = townListData {
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
