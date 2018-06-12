//
//  FindWithCityName.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 26..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit
import MapKit

class FindWithCityName: UIViewController, CLLocationManagerDelegate, CityBase {
    @IBOutlet var cityName: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var showMapButton: UIBarButtonItem!
    
    var cities: [City]!
    var cityData: CityListData?
    var townData: TownListData?
    var apiKey: String = ""
    let cityPicker = UIPickerView()
    var medicalController: MedicalController!
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    var activityIndicator = UIActivityIndicatorView()
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if false == checkCanSearch() {
            searchButton.isEnabled = false
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        medicalController = MedicalController(tableView: self.tableView)
        
        // delegate에 정보 전달
        if let title = self.title {
            medicalController.key = apiKey
            medicalController.cityName = cityName.text
            switch title {
            case "병원":
                medicalController.url = "https://openapi.gg.go.kr/Animalhosptl?pSize=50&Type=xml"
            case "약국":
                medicalController.url = "https://openapi.gg.go.kr/AnimalPharmacy?pSize=50&Type=xml"
            default:
                break
            }
            medicalController.cellIdentifier = "MedicalCell"
        }
        
        tableView.delegate = medicalController
        tableView.dataSource = medicalController
        
        for city in cities {
            if city.name == "경기도" {
                townData = TownListData(owner: self, towns: city.towns)
            }
        }
        
        cityPicker.delegate = townData
        cityName.inputView = cityPicker
        cityName.inputAccessoryView = createToolBar(select: #selector(donePressed))
        cityName.text = townData!.towns.first!.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getCurrLocation(_ sender: UIBarButtonItem) {
        locationManager.requestWhenInUseAuthorization()
        showWaitIcon()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        effectView.removeFromSuperview()
        guard
            let coord = locations.last?.coordinate,
            let addrData = addressModule.getAddressData(coord: coord)
        else {
            return
        }
        
        if addrData.sidoName != "경기도" {return}
        
        if let tData = townData {
            if let idx = tData.towns.index(where: {t in return t.name == addrData.sigunguName }) {
                tData.selectedRow = idx
                townSelected(index: idx)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        effectView.removeFromSuperview()
        let alert = UIAlertController(title: "오류", message: "지원되지 않는 지역입니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: UIButton!) {
        searchButton.isEnabled = false
        showWaitIcon()
        DispatchQueue.main.async {
            self.medicalController.cityName = self.cityName.text
            self.medicalController.clearData()
            self.medicalController.search(page: self.medicalController.currPage)
            if self.medicalController.hospitalList.isEmpty {
                self.showMapButton.isEnabled = false
            } else {
                self.showMapButton.isEnabled = true
            }
            DispatchQueue.main.async {
                self.effectView.removeFromSuperview()
                self.searchButton.isEnabled = true
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showHospitalDetail", "showPharmacyDetail":
            if let cell = sender as? UITableViewCell{
                if let index = tableView.indexPath(for: cell) {
                    if let navController = segue.destination as? UINavigationController {
                        if let controller = navController.topViewController as? MedicalDetailController{
                            controller.data = medicalController.hospitalList[index.row]
                            if segue.identifier == "showHospitalDetail" {
                                controller.cellIdentifier = "HospitalCell"
                            } else {
                                controller.cellIdentifier = "PharmacyCell"
                            }
                        }
                    }
                }
            }
        case "showMapView":
            if let controller = segue.destination as? MapViewController {
                for data in medicalController.hospitalList {
                    var address: String? = nil
                    if let addr = data["REFINE_LOTNO_ADDR"] {
                        address = addr
                    } else if let addr = data["REFINE_ROADNM_ADDR"] {
                        address = addr
                    }
                    
                    if let anno = MapAnnotation.fromData(title: data["BIZPLC_NM"]!, address: address, lat: data["REFINE_WGS84_LAT"], lon: data["REFINE_WGS84_LOGT"]) {
                        controller.mapAnnotations.append(anno)
                    }
                }
                if let first = controller.mapAnnotations.first {
                    controller.initialLoca = CLLocation(latitude: first.coordinate.latitude, longitude: first.coordinate.longitude)
                }
            }
        default:
            break
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
    
    func createToolBar(select: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: select)
        toolBar.items = [flexBar, doneBtn]
        return toolBar
    }
    
    @objc func donePressed() {
        cityName.resignFirstResponder()
    }
    
    func citySelected(index: Int) {
        
    }
    
    func townSelected(index: Int) {
        cityName.text = townData?.towns[index].name
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

class FindHospital: FindWithCityName {
    @IBAction func doneToHospitalSearchView(segue: UIStoryboardSegue){}
}

class FindPharmacy: FindWithCityName {
    @IBAction func doneToPharmacySearchView(segue: UIStoryboardSegue){}
}
