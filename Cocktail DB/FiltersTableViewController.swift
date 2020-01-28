//
//  FiltersTableViewController.swift
//  Cocktail DB
//
//  Created by Anastasia on 24.01.2020.
//  Copyright © 2020 Anastasia. All rights reserved.
//
import UIKit

class FiltersTableViewController: UITableViewController {
    @IBOutlet var applyButton: UIButton!
    
    var allFiltersArray = [String]()
    var selectedFilters = [String]()
    var selectedFiltersWereChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(FiltersTableViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isApplyButtonActive(active: false)
        
        selectedFilters = UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? [String]()
        
        if  selectedFilters.isEmpty == true && allFiltersArray.isEmpty != true  {
            UserDefaults.standard.set(self.allFiltersArray, forKey: "selectedCategories")
            UserDefaults.standard.set(selectedFiltersWereChanged, forKey: "selectedFiltersWereChanged")
            selectedFilters = self.allFiltersArray
            UserDefaults.standard.synchronize()
        }
        if selectedFilters.isEmpty != true && allFiltersArray.isEmpty != true {
            for item in selectedFilters{
                if let index = allFiltersArray.firstIndex(of: item) {
                    let indexPath = IndexPath(row: index, section: 0)
                    tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
                }
            }
        }
    }

// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFiltersArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filtersCell", for: indexPath)
        if allFiltersArray.isEmpty != true {
            cell.textLabel?.text = allFiltersArray[indexPath.row]
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            if selectedFilters.count <= 1 {
                showAlert(title: "Error", message: "Must be selected at least one category!", action: "Ok")
            } else {
                selectedFilters = selectedFilters.filter{$0 != allFiltersArray[indexPath.row]}
                selectedFilters = sort()
                UserDefaults.standard.set(selectedFilters, forKey: "recentlySelectedCategories")
                checkChangesInSelectedFilters()
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            selectedFilters.append(allFiltersArray[indexPath.row])
            selectedFilters = sort()
            UserDefaults.standard.set(selectedFilters, forKey: "recentlySelectedCategories")
            checkChangesInSelectedFilters()
        }
    }
    
    
    func sort() -> [String]{
        var temp = [Int]()
        if let categ = DataManager.sharedInstance.categories {
            for i in selectedFilters {
                for item in categ {
                    if item.categoryName == i {
                        if let id = item.id{
                            temp.append(id)
                        }
                    }
                }
            }
        }
        temp.sort()
        
        var result = [String]()
        if let categ = DataManager.sharedInstance.categories {
            for i in temp {
                for item in categ {
                    if item.id == i {
                        if let name = item.categoryName{
                            result.append(name)
                        }
                    }
                }
            }
        }
        return result
    }
    
    
    func checkChangesInSelectedFilters(){
        if UserDefaults.standard.stringArray(forKey: "recentlySelectedCategories") ?? [String]() == UserDefaults.standard.stringArray(forKey: "selectedCategories") ?? [String]() {
            selectedFiltersWereChanged = false
            isApplyButtonActive(active: false)
        } else {
            selectedFiltersWereChanged = true
            isApplyButtonActive(active: true)
        }
    }
    
    
    @objc func back(sender: UIBarButtonItem) {
        checkChangesInSelectedFilters()
        UserDefaults.standard.set(false, forKey: "selectedFiltersWereChanged")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func applyChanges(_ sender: Any) {
        UserDefaults.standard.set(selectedFilters, forKey: "selectedCategories")
        UserDefaults.standard.set(selectedFiltersWereChanged, forKey: "selectedFiltersWereChanged")
        UserDefaults.standard.synchronize()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func isApplyButtonActive(active: Bool){
        if active == true {
            applyButton.isEnabled = true
            applyButton.backgroundColor = UIColor.systemBlue
        } else {
            applyButton.isEnabled = false
            applyButton.backgroundColor = UIColor.lightGray
        }
    }
    
    
    func showAlert(title: String, message: String, action: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
}
