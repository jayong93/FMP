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

class MedicalController: UITableViewController, XMLParserDelegate {
    @IBOutlet var dataTable: UITableView!
    var cityName: String?
    var key: String = ""
    var url = ""
    var cellIdentifier = ""
    var currPage = 1
    var maxRowNumStr = ""
    var maxRowNum = 0
    var isInDataSection = false // row element를 만나면 true, 끝나면 false
    var hospitalList: [[String:String]] = []
    var currentData: [String:String] = [:]
    var currentElement: String?
    var noMoreData = false
    
    let itemIdentifier = "row"
    let totalCntIdentifier = "list_total_count"
    let rowNumOfPage = 100
    
    func search(page: Int) {
        let fullURL = url + "&KEY=\(key)&SIGUN_NM=\(cityName ?? "")&pIndex=\(page)&pSize=\(rowNumOfPage)"
        let encodedURL = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = encodedURL {
            let parser = XMLParser(contentsOf: URL(string: url)!)
            if let p = parser {
                p.delegate = self
                p.parse()
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == itemIdentifier {
            isInDataSection = true
            currentData = [:]
        }
        else if isInDataSection || elementName == totalCntIdentifier {
            maxRowNumStr = ""
            currentElement = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let element = currentElement {
            let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
            if isInDataSection {
                if let oldValue = currentData[element] {
                    currentData[element] = oldValue + string
                } else {
                    currentData[element] = string
                }
            }
            else {
                maxRowNumStr += string
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
        } else if elementName == totalCntIdentifier {
            currentElement = nil
            maxRowNum = Int(maxRowNumStr)!
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell{
            if let index = tableView.indexPath(for: cell) {
                if let controller = segue.destination as? MedicalDetailController {
                    controller.data = hospitalList[index.row]
                    if segue.identifier == "showHospitalDetail" {
                        controller.cellIdentifier = "HospitalCell"
                    } else {
                        controller.cellIdentifier = "PharmacyCell"
                    }
                }
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
        dataTable.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        cell.textLabel!.text = hospitalList[indexPath.row]["BIZPLC_NM"]
        
        cell.detailTextLabel!.text = nil
        if let addr = hospitalList[indexPath.row]["REFINE_ROADNM_ADDR"] {
            if false == addr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                cell.detailTextLabel!.text = addr
            }
        }
        if cell.detailTextLabel!.text == nil {
            if let addr = hospitalList[indexPath.row]["REFINE_LOTNO_ADDR"] {
                cell.detailTextLabel!.text = addr
            }
        }
        
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if currPage * rowNumOfPage < maxRowNum {
                let oldCount = hospitalList.count
                currPage += 1
                search(page: currPage)
                
                var newRows: [IndexPath] = []
                for i in oldCount..<hospitalList.count {
                    newRows.append(IndexPath(row: i, section: 0))
                }
                
                if !newRows.isEmpty {
                    tableView.insertRows(at: newRows, with: .bottom)
                }
            }
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
