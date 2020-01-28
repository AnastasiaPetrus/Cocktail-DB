//
//  Category.swift
//  Cocktail DB
//
//  Created by Anastasia on 25.01.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Category: NSObject {
    
    var categoryName: String?
    var id: Int?
    var cocktails: [Cocktail]?

}
