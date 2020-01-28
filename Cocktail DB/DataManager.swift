//
//  DataManager.swift
//  Cocktail DB
//
//  Created by Anastasia on 25.01.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DataManager: NSObject {
    
    static let sharedInstance = DataManager()
    
    var dataLoader = DataLoader()
    var categories: [Category]?
    var categoryName: String?

    
    func fetchCategories(completionHandler: @escaping (_ result: [String]?, _ error: String?) -> Void){
        dataLoader.generateURL(type: "list")
        dataLoader.sendRequest() {(response, error) in
            self.parseCategoriesJSON(gotJSON: response) {(result, error) in
                if let resultArray = result {
                    self.categories?.removeAll()
                    var temp = [Category]()
                    var id = 0
                    for newCategory in resultArray{
                        let category = Category()
                        category.categoryName = newCategory
                        category.id = id
                        temp.append(category)
                        id += 1
                    }
                    self.categories = temp
                }
                completionHandler(result, error)
            }
        }
    }

    
    func fetchCocktails(category: Category, completionHandler: @escaping (_ result: [Cocktail]?, _ error: String?) -> Void){
        if let categoryName = category.categoryName {
        dataLoader.generateURL(type: categoryName)
            dataLoader.sendRequest() {(response, error) in
                self.parseCocktailsJSON(gotJSON: response, nameCategory: categoryName) {(result, error) in
                    category.cocktails = result
                    completionHandler(result, error)
                }
            }
        }
    }

    
    func parseCategoriesJSON(gotJSON: Any?, completionHandler: @escaping (_ result: [String]?, _ error: String?) -> Void){
        var resultArray = [String]()
        if let JSON = gotJSON as? JSON {
            for category in JSON["drinks"].arrayValue {
                resultArray.append(category["strCategory"].stringValue)
            }
            completionHandler(resultArray, nil)
        }
    }
    
    
    func parseCocktailsJSON(gotJSON: Any?, nameCategory: String, completionHandler: @escaping (_ result: [Cocktail]?, _ error: String?) -> Void) {
        var resultArray = [Cocktail]()
        if let JSON = gotJSON as? JSON {
            for drink in JSON["drinks"].arrayValue {
                var cocktail = Cocktail()
                cocktail.category = nameCategory
                cocktail.imageURL = "\(drink["strDrinkThumb"].stringValue)/preview"
                cocktail.title = drink["strDrink"].stringValue
                resultArray.append(cocktail)
            }
            completionHandler(resultArray, nil)
        }
    }
    

}
