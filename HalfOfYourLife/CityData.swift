//
//  CityData.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 28..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import Foundation
import UIKit

struct Town {
    var name: String
    var code: String
}

struct City {
    var name: String
    var code: String
    var towns: [Town]
}

class CityListData: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    let owner: CityBase
    var selectedRow = 0
    
    init(owner: CityBase) {
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
    let owner: CityBase
    var towns: [Town]
    var selectedRow = 0
    
    init(owner: CityBase, towns: [Town]) {
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

protocol CityBase {
    var cities: [City]! {get}
    var cityData: CityListData? {get}
    var townData: TownListData? {get}
    
    func citySelected(index: Int)
    func townSelected(index: Int)
}
