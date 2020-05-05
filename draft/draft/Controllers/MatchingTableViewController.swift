//
//  MatchingTableViewController.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class MatchingTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var roomGroup: RoomGroup
    
    lazy var numOfSections: Int? = roomGroup.keys.count
    
    required init?(coder: NSCoder) {
        roomGroup = RoomGroup()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchController()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
 
        return numOfSections ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let keys = [GameDate](roomGroup.keys)
        let numOfRooms = roomGroup[keys[section]]?.count
        
        return numOfRooms ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room identifier", for: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        // Header에 뜰 Date format 정하면 사용할 값들
        // let keys = [GameDate](roomGroup.keys)
        // let date = keys[section]
        // let dateString = DateFormatter().string(from: date)
        return "오늘의 경기"
    }
    
    // Mark: - add search bar to Navgation Controller
    
    //    func addSearchBar() {
    //        let searchBar = UISearchBar()
    //        searchBar.showsCancelButton = true
    //        searchBar.placeholder = "방을 검색해보세요!"
    //        searchBar.delegate = self
    //
    //        self.navigationItem.titleView = searchBar
    //    }
    //
    // MARK: - SearchBarController
    func addSearchController(){
        
        let searchBarController = UISearchController(searchResultsController: nil)
        
        self.navigationItem.searchController = searchBarController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
