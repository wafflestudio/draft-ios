//
//  MatchingTableViewController.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class MatchingTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var roomGroup: RoomGroup?
    
    lazy var numOfSections: Int? = 1 // 나중에 AllRooms class의 count로 수정
    
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
        
        let numOfRooms = roomGroup?.count
        
        return numOfRooms ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room identifier", for: indexPath)

        // label sample
        let index = indexPath.row
        cell.textLabel?.text = roomGroup?[index]?.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // 나중에 AllRooms model 만들면 수정
        return roomGroup?.getDateInString()
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createRoomSegue" {
            
            if let createRoomViewController = segue.destination as? RoomDetailViewController {
                createRoomViewController.delegate = self
                createRoomViewController.roomGroup = roomGroup
            }
        }
    }
}

extension MatchingTableViewController: RoomDetailViewControllerDelegate {
    func roomDetailViewController(_ controller: RoomDetailViewController, didFinishAdding item: Room) {
        tableView.reloadData()
    }
}
