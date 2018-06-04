//
//  FindWithCityName.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 26..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

class FindWithCityName: UIViewController, CityBase {
    @IBOutlet var cityName: UITextField!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var cities: [City]!
    var cityData: CityListData?
    var townData: TownListData?
    var apiKey: String = ""
    let cityPicker = UIPickerView()
    var medicalController: MedicalController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if false == checkCanSearch() {
            searchButton.isEnabled = false
        }
        
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
    
    @IBAction func search(_ sender: UIButton!) {
        medicalController.cityName = cityName.text
        medicalController.clearData()
        medicalController.search(page: medicalController.currPage)
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell{
            if let index = tableView.indexPath(for: cell) {
                if let controller = segue.destination as? MedicalDetailController {
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
}
