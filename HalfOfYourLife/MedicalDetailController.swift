//
//  HospitalDetailController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
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

class MedicalDetailController: UITableViewController {
    var data: [String:String] = [:]
    var viewData: [(String, String)] = []
    var cellIdentifier: String = ""
    let keyLabels = [("BIZPLC_NM", "사업장명"), ("LICENSG_DE", "인허가일자"), ("LOCPLC_AR", "소재지 면적(㎡)"), ("TOT_EMPLY_CNT", "총종업원수"), ("REFINE_ROADNM_ADDR", "도로명 주소"), ("REFINE_ZIP_CD", "우편번호")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for (key, label) in keyLabels {
            let val = data[key] ?? ""
            if !val.isEmpty {
                viewData.append((label, val))
            } else if key == "REFINE_ROADNM_ADDR" {
                if let addr = data["REFINE_LOTNO_ADDR"] {
                    viewData.append(("지번 주소", addr))
                }
            }
        }
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
        return viewData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        cell.textLabel!.text = viewData[indexPath.row].0
        cell.detailTextLabel!.text = viewData[indexPath.row].1
        
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.minimumScaleFactor = 0.2
        return cell
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
