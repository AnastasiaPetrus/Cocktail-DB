//
//  DataLoader.swift
//  Cocktail DB
//
//  Created by Anastasia on 24.01.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DataLoader: NSObject {
    var url: String?
    
    func generateURL(type:String){
        switch type {
        case "list":
            url = "https://www.thecocktaildb.com/api/json/v1/1/list.php?c=list"
        default:
            url = "https://www.thecocktaildb.com/api/json/v1/1/filter.php?c=\(type.replacingOccurrences(of: " ", with: "_"))"
        }
    }
    
    
    func sendRequest(completionHandler: @escaping (_ result: Any?, _ error: String?) -> Void){
        if let url = self.url {
            Alamofire.request(url).responseJSON { response in
                if response.result.isSuccess {
                    if let resp = response.result.value {
                       completionHandler(JSON(resp), nil)
                    }
                } else {
                    if let _ = response.result.value {
                        let error: String? = "Error. \nProblems with loading data."
                        completionHandler(nil, error)
                    }
                }
            }
        }
    }
}
