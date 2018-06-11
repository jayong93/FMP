//
//  PetDetailController.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 28..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import UIKit
import Foundation

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

class PetDetailController: UIViewController {
    @IBOutlet var petImage: UIImageView!
    @IBOutlet var raceLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var neutralizedLabel: UILabel!
    @IBOutlet var foundLocLabel: UILabel!
    @IBOutlet var careLabel: UILabel!
    @IBOutlet var careNumLabel: UILabel!
    @IBOutlet var labels: [UILabel]!
    
    var petData: [String:String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for label in labels {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
        }

        if let imgStr = petData["popfile"] {
            if let imgURL = URL(string: imgStr) {
                if let data = try? Data(contentsOf: imgURL) {
                    petImage.image = UIImage(data: data)
                    petImage.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin,.flexibleLeftMargin,.flexibleRightMargin,.flexibleHeight,.flexibleWidth]
                    petImage.contentMode = .scaleAspectFit
                }
            }
        }
        
        var race = ""
        if let raceStr = petData["kindCd"] {
            let racePtn = "\\[.+\\]\\s*(.+)"
            if let regex = try? NSRegularExpression(pattern: racePtn, options: []) {
                if let match = regex.firstMatch(in: raceStr, options: [], range: NSRange(raceStr.startIndex..<raceStr.endIndex, in: raceStr)) {
                    let range = Range.init(match.range(at: 1), in: raceStr)!
                    race += raceStr[range]
                }
            }
        }
        let sexStr = petData["sexCd"]
        if sexStr == "M" {
            race += "(남)"
        } else if sexStr == "F" {
            race += "(여)"
        }
        raceLabel.text = race
        
        if let age = petData["age"] {
            ageLabel.text = "나이: \(age)"
        } else {
            ageLabel.text = "나이 알 수 없음."
        }
        
        if let weight = petData["weight"] {
            weightLabel.text = "체중: \(weight)"
        } else {
            weightLabel.text = nil
        }
        
        let neutralized = petData["neuterYn"]
        if neutralized == "Y" {
            neutralizedLabel.text = "중성화 됨."
        } else if neutralized == "N" {
            neutralizedLabel.text = "중성화 되지 않음."
        } else {
            neutralizedLabel.text = nil
        }
        
        if let foundPlace = petData["happenPlace"] {
            foundLocLabel.text = "\(foundPlace) 에서 발견됨."
        } else {
            foundLocLabel.text = nil
        }
        
        if let careAddr = petData["careAddr"] {
            if let careName = petData["careNm"] {
                careLabel.text = "\(careName)(\(careAddr)) 에서 보호 중."
            } else {
                careLabel.text = "\(careAddr) 에서 보호 중."
            }
        } else {
            careLabel.text = nil
        }
        
        if let careNum = petData["careTel"] {
            careNumLabel.text = "연락처: \(careNum)"
        } else if let officeNum = petData["officetel"] {
            careNumLabel.text = "연락처: \(officeNum)"
        } else {
            careNumLabel.text = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
