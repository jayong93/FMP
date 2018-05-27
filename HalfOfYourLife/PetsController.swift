//
//  PetsController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit

/*
 항목명(국문)     항목명(영문)     항목크기     항목구분     샘플데이터     항목설명
 공고종료일     noticeEdt     8     1     20140303     공고종료일 (YYYYMMDD)
 Image     popfile     100     1     http://www.animal.go.kr/files/shelter/2014/02/201403010903285.jpg     Image
 상태     processState     10     1     종료(입양)     상태
 성별     sexCd     1     1     F     M : 수컷 F : 암컷 Q : 미상
 중성화여부     neuterYn     1     1     Y     Y : 예 N : 아니오 U : 미상
 특징     specialMark     200     1     치석있으며건강함     특징
 보호소이름     careNm     50     1     유기동물보호소     보호소이름
 보호소전화번호     careTel     14     1     02-123-4567     보호소전화번호
 보호장소     careAddr     200     1     서울특별시 양천구 신월3동     보호장소
 관할기관     orgNm     50     1     서울특별시 양천구     관할기관
 담당자     chargeNm     20     1     홍길동     담당자
 담당자연락처     officetel     14     1     02-1111-2222     담당자연락처
 특이사항     noticeComment     200     1     없음     특이사항
 한 페이지결과수     numOfRows     4     1     10     한페이지 결과수
 페이지 번호     pageNo     4     1     1     페이지 번호
 전체 결과 수     totalCount     4     1     6840     전체 결과 수
 결과코드     resultCode     2     1     00     결과코드
 결과메세지     resultMsg     50     1     NORMAL SERVICE.     결과메세지
 유기번호     desertionNo     20     1     411314201400052     유기번호
 Thumbnail Image     filename     100     1     http://www.animal.go.kr/files/shelter/2014/02/201403010903285_s.jpg     Thumbnail Image
 접수일     happenDt     8     1     20140301     접수일 (YYYYMMDD)
 발견장소     happenPlace     100     1     신월3동195-1     발견장소
 품종     kindCd     50     1     [개] 믹스견     품종
 색상     colorCd     30     1     갈/검/흰     색상
 나이     age     30     1     3살추정     나이
 체중     weight     30     1     3.8(Kg)     체중
 공고번호     noticeNo     30     1     서울-양천-2014-00050     공고번호
 공고시작일     noticeSdt     8     1     20140303     공고시작일 (YYYYMMDD)
 */

class PetsController: UITableViewController, XMLParserDelegate {
    var apiKey = ""
    var startDate = ""
    var endDate = ""
    var cityCode = ""
    var townCode: String?
    var maxPage = 1
    var isInDataSection = false // item element를 만나면 true, 끝나면 false
    var petList: [[String:String]] = []
    var currentData: [String:String] = [:]
    var currentElement: String?
    
    let baseURL = "http://openapi.animal.go.kr/openapi/service/rest/abandonmentPublicSrvc/abandonmentPublic?"
    let itemIdentifier = "item"
    let cellIdentifier = "PetCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        search(page: 1)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func search(page: Int) {
        var fullURL = baseURL + "&serviceKey=\(apiKey)&bgnde=\(startDate)&endde=\(endDate)&pageNo=\(page)&numOfRows=20"
        if let townCd = townCode {
            fullURL += "&org_cd=\(townCd)"
        } else {
            fullURL += "&upr_cd=\(cityCode)"
        }
        let parser = XMLParser(contentsOf: URL(string: fullURL)!)
        if let p = parser {
            p.delegate = self
            p.parse()
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
            petList.append(currentData)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return petList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let data = petList[indexPath.row]
        
        // 썸네일 로딩해서 표시
        if let imgURL = data["filename"] {
            if let url = URL(string: imgURL) {
                if let imgData = try? Data(contentsOf: url) {
                    cell.imageView?.image = UIImage(data: imgData)
                }
            }
        }
        cell.textLabel!.text = data["kindCd"]
        cell.detailTextLabel?.text = data["age"]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row+1 == petList.count {
            let oldCount = petList.count
            maxPage += 1
            search(page: maxPage)
            
            tableView.reloadData()
            tableView.scrollToRow(at: IndexPath(row: oldCount-1, section: 0), at: .bottom, animated: true)
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
