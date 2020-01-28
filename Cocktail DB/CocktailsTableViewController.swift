//
//  CocktailsTableViewController.swift
//  Cocktail DB
//
//  Created by Anastasia on 24.01.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class CocktailsTableViewController: UITableViewController {
    @IBOutlet var editButton: UIBarButtonItem!

    var shownCategoriesArray = [String?]()
    var allCategoriesArray = [String?]()
    var cocktailsDictionary = [String : [Cocktail?]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "selectedFiltersWereChanged")
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        tableView.rowHeight = 116
        tableView.separatorColor = UIColor.gray
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if DataManager.sharedInstance.categories?.count == nil {
            getCategory()
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAppliedFilters()
    }
// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return shownCategoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if shownCategoriesArray.isEmpty != true {
            return shownCategoriesArray[section]
        } else {
            return "Loading..."
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cocktailsDictionary[shownCategoriesArray[section] ?? ""]?.count == 0 || cocktailsDictionary[shownCategoriesArray[section] ?? ""]?.count == nil && section == 0 {
             getListOfCocktailsForCategory(index: section)
        }
        return cocktailsDictionary[shownCategoriesArray[section] ?? ""]?.count ?? 0
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        if indexPath.section + 1 <= shownCategoriesArray.count-1 &&  tableView.numberOfRows(inSection: indexPath.section + 1) == 0{
            if let nameOfCategory = shownCategoriesArray[indexPath.section] {
                if let list = cocktailsDictionary[nameOfCategory] {
                    if indexPath.row == list.count-1{
                        getListOfCocktailsForCategory(index: indexPath.section + 1)
                    }
                }
            }
        }

        if indexPath.section - 1 >= 0  &&  tableView.numberOfRows(inSection: indexPath.section - 1) == 0{
            if indexPath.row == 0{
                getListOfCocktailsForCategory(index: indexPath.section - 1)
            }
        }

        if cocktailsDictionary.isEmpty != true && shownCategoriesArray.isEmpty != true {
            if let nameOfCategory = shownCategoriesArray[indexPath.section] {
                if let category = cocktailsDictionary[nameOfCategory] {
                    if let title = category[indexPath.row]?.title {
                        cell.label.text = title
                    } else {
                        cell.label.text = "Loading..."
                    }
                    if let imageURL = category[indexPath.row]?.imageURL {
                        cell.imageView?.contentMode = .scaleAspectFit
                        cell.imageView?.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "default"))
                    } else {
                        cell.imageView?.image = UIImage(named: "default")
                    }
                }
            }
        }
        return cell
    }
    
    
    func scrollTableView(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0.3, animations: { self.setScroll()})
            { _ in completion() }
    }
    
    
    func setScroll(){
        let selectedFiltersWereChanged = UserDefaults.standard.bool(forKey: "selectedFiltersWereChanged")
        if selectedFiltersWereChanged == true {
            if self.numberOfSections(in: self.tableView) != 0, self.tableView(self.tableView, numberOfRowsInSection: 0) != 0,  self.tableView.visibleCells.isEmpty != true{
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
// MARK: - Load data
    
    func getListOfCocktailsForCategory(index:Int){
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.label.text = "Loading"
        
        if let categoryName = self.shownCategoriesArray[index] {
            let category = Category()
            category.categoryName = categoryName
            DataManager.sharedInstance.fetchCocktails(category: category) { (response, error)  in
                self.cocktailsDictionary[categoryName] = response
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }

    
    func getCategory(){
        DataManager.sharedInstance.fetchCategories { (response, error) in
            if let resp = response, error == nil{
                var temp = [String]()
                for categoryName in resp {
                    temp.append(categoryName)
                }
                self.shownCategoriesArray = temp
                self.allCategoriesArray = temp
                
                self.checkAppliedFilters()
                self.getListOfCocktailsForCategory(index: 0)

            } else {
                self.showAlert(title: "Alert", message:  error ?? "Error.", action: "Ok")
            }
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
//MARK: - Additional methods
    
    func checkAppliedFilters(){
        let selectedCategories: [String] = UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? [String]()
        if selectedCategories.count == 0 {
            if shownCategoriesArray.count == 0 {
                for category in self.allCategoriesArray {
                    if let temp = category {
                        self.shownCategoriesArray.append(temp)
                    }
                    
                }
            }
        updateButton(isActive: false, numberOfSelectedCategories: shownCategoriesArray.count)
        } else {
            shownCategoriesArray = selectedCategories
            if shownCategoriesArray.isEmpty == true {
                updateButton(isActive: false, numberOfSelectedCategories: shownCategoriesArray.count)
            } else {
                updateButton(isActive: true, numberOfSelectedCategories: shownCategoriesArray.count)
            }
        }
        tableView.reloadData {
            self.scrollTableView {
                self.setScroll()
            }
        }
    }

    
    func updateButton(isActive: Bool, numberOfSelectedCategories: Int){
        if isActive == false {
            editButton.tintColor = UIColor.gray
            editButton.title = "Applied: \(numberOfSelectedCategories)"
        } else {
            editButton.tintColor = UIColor.systemBlue
            editButton.title = "Applied: \(numberOfSelectedCategories)"
        }
    }
    

    func showAlert(title: String, message: String, action: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFilters" {
            if let filtersTableVC = segue.destination as? FiltersTableViewController {
                if self.shownCategoriesArray.isEmpty != true {
                    filtersTableVC.allFiltersArray = self.allCategoriesArray as? [String] ?? []
                }
            }
        }
    }
}


extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
            { _ in completion() }
    }
}
