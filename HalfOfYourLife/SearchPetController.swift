//
//  SearchPetController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class SearchPetController: UIViewController, CLLocationManagerDelegate, CityBase {
    
    @IBOutlet var cityListView: UITextField!
    @IBOutlet var townListView: UITextField!
    @IBOutlet var searchStartDate: UITextField!
    @IBOutlet var searchEndDate: UITextField!
    @IBOutlet var searchBtn: UIButton!
    @IBOutlet var getLocationButton: UIBarButtonItem!
    
    var apiKey = ""
    let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/"
    var cities: [City]!
    var cityData: CityListData?
    var cityPicker = UIPickerView()
    var townData: TownListData?
    var townPicker = UIPickerView()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    var activityIndicator = UIActivityIndicatorView()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        setBackground(path: "pet_background.png")

        if let key = getAPIKey() {
            apiKey = key
            
            // 전지역 entry 추가
            var all_city: [City] = [City(name: "전지역", code: "", towns: [])]
            all_city.append(contentsOf: cities)
            cities = all_city
            
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
            townListView.text = cities.first!.towns.first?.name
            townListView.isEnabled = false
            
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
                    if !townData.towns.isEmpty {
                        controller.townCode = townData.towns[townData.selectedRow].code
                    }
                }
            }
        }
    }
    
    @IBAction func getCurrLocation(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        getLocationButton.isEnabled = false
        searchBtn.isEnabled = false
        showWaitIcon()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        effectView.removeFromSuperview()
        getLocationButton.isEnabled = true
        searchBtn.isEnabled = true
        guard
        let coord = locations.last?.coordinate,
        let addrData = addressModule.getAddressData(coord: coord)
        else {return}
        
        if let cData = cityData {
            if let idx = cities.index(where: {city in return city.name == addrData.sidoName}) {
                cData.selectedRow = idx
                citySelected(index: idx)
            }
        }
        if let tData = townData {
            if let idx = tData.towns.index(where: {town in return town.name == addrData.sigunguName}) {
                tData.selectedRow = idx
                townSelected(index: idx)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        effectView.removeFromSuperview()
        getLocationButton.isEnabled = true
        searchBtn.isEnabled = true
        let alert = UIAlertController(title: "오류", message: "위치 정보를 가져올 수 없습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
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
    
    func setBackground(path: String) {
        if let bgImg = UIImage(named: path) {
            let boundWidth = self.view.bounds.width
            let boundHeight = self.view.frame.maxY - searchBtn.frame.maxY
            
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: boundWidth, height: boundHeight))
            imgView.contentMode = .scaleAspectFit
            imgView.clipsToBounds = true
            imgView.image = bgImg
            imgView.center = CGPoint(x: self.view.frame.midX, y: (self.view.frame.maxY + searchBtn.frame.minY)/2 - 20)
            self.view.addSubview(imgView)
            self.view.sendSubview(toBack: imgView)
        }
    }
    
    func showWaitIcon() {
        effectView.frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y-25, width: 50, height: 50)
        effectView.layer.masksToBounds = true
        effectView.layer.cornerRadius = 15
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        self.view.addSubview(effectView)
    }
}
