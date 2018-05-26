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
    var apiKey: String = ""
    
    @IBAction func doSearch(_ sender: Any) {
    }
    
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
