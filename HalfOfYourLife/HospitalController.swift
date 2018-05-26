//
//  HospitalController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 26..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

/*
 결과 포맷
 1    SIGUN_NM    시군명
 2    SIGUN_CD    시군코드
 3    BIZPLC_NM    사업장명
 4    LICENSG_DE    인허가일자
 5    BSN_STATE_NM    영업상태명
 6    CLSBIZ_DE    폐업일자
 7    LOCPLC_AR    소재지면적(㎡)
 8    LOCPLC_ZIP_CD    소재지우편번호
 9    TOT_EMPLY_CNT    총종업원수
 10    SFRMPROD_PROCSBIZ_DIV_NM    축산물가공업구분명
 11    STOCKRS_DUTY_DIV_NM    축산업무구분명
 12    REFINE_LOTNO_ADDR    소재지지번주소
 13    REFINE_ROADNM_ADDR    소재지도로명주소
 14    REFINE_ZIP_CD    소재지우편번호
 15    REFINE_WGS84_LAT    WGS84위도
 16    REFINE_WGS84_LOGT    WGS84경도
 */

class HospitalController: UITableViewController, XMLParserDelegate {
    @IBOutlet var dataTable: UITableView!
    var cityName: String?
    var key: String = ""
    let url = "https://openapi.gg.go.kr/Animalhosptl?pSize=50&Type=xml"
    let itemIdentifier = "row"
    var maxPage = 1
    var isInDataSection = false // row element를 만나면 true, 끝나면 false
    var hospitalList: [[String:String]] = []
    var currentData: [String:String] = [:]
    var currentElement: String?
    
    func search(page: Int) {
        let fullURL = url + "&KEY=\(key)&SIGUN_NM=\(cityName ?? "")&pIndex=\(page)"
        let parser = XMLParser(contentsOf: URL(string: fullURL)!)
        if let p = parser {
            p.delegate = self
            p.parse()
            dataTable.reloadData()
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == itemIdentifier {
            isInDataSection = true
            currentData = [:]
        }
        else if isInDataSection {
            currentElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let element = currentElement {
            let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if let oldValue = currentData[element] {
                currentData[element] = oldValue + string
            } else {
                currentData[element] = string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == itemIdentifier {
            isInDataSection = false
            currentElement = nil
            // 운영중인 병원만 표시
            if currentData["BSN_STATE_NM"] == "운영중" {
                hospitalList.append(currentData)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        search(page:1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return hospitalList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell", for: indexPath)

        cell.textLabel!.text = hospitalList[indexPath.row]["BIZPLC_NM"]
        cell.detailTextLabel!.text = hospitalList[indexPath.row]["REFINE_ROADNM_ADDR"]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row+1 == hospitalList.count {
            let oldCount = hospitalList.count
            maxPage += 1
            search(page: maxPage)
            
            var rows: [IndexPath] = []
            for i in oldCount..<hospitalList.count {
                rows.append(IndexPath(row: i, section: 0))
            }
            
            dataTable.beginUpdates()
            dataTable.insertRows(at: rows, with: .automatic)
            dataTable.endUpdates()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
