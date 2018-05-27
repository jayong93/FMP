//
//  Parsers.swift
//  HalfOfYourLife
//
//  Created by  KPU_GAME on 2018. 5. 27..
//  Copyright © 2018년 KPU_GAME. All rights reserved.
//

import Foundation

class SidoParser: NSObject, XMLParserDelegate{
    var sidoCodes: [(String, String)] = []
    private var currentData: (String, String)?
    private var currentElement: String?
    private let dataIdentifier = "item"
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == dataIdentifier {
            currentData = ("", "")
        } else {
            currentElement = elementName
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let (name, code) = currentData {
            if let curElem = currentElement {
                if curElem == "orgCd" {
                    let newCode = code + string.trimmingCharacters(in: .whitespacesAndNewlines)
                    currentData = (name, newCode)
                } else if curElem == "orgdownNm" {
                    let newName = name + string.trimmingCharacters(in: .whitespacesAndNewlines)
                    currentData = (newName, code)
                }
            }
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == dataIdentifier {
            sidoCodes.append(currentData!)
            currentData = nil
        }
    }
}
