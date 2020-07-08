//
//  MatchingTableViewController.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class MatchingTableViewController: UITableViewController, UISearchBarDelegate {
    
    internal var roomGroup: RoomGroup?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchController()
        allRoomsAPIRequest()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return roomGroup?.getNumOfRoomDate() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let values = roomGroup?.roomGroup.values {
            
            let roomsByDate = [RoomsByDate](values)
            let numOfRooms = roomsByDate[section].count
            
            return numOfRooms
            
        } else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "room identifier", for: indexPath)
        
        let index = indexPath.row
        let section = indexPath.section
        
        if let values = roomGroup?.roomGroup.values {
            
            let roomsByDateArray = [RoomsByDate](values)
            let name = roomsByDateArray[section][index]?.name
            cell.textLabel?.text = name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let keys = roomGroup?.roomGroup.keys {
            let dates = [GameDateString](keys)
            
            let date = dates[section]
            
            return date
        } else { return nil }
        
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
    
    // MARK: - Prepare for Room Detail (Create Room as well)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "createRoomSegue" {
            
            if let createRoomViewController = segue.destination as? RoomDetailViewController {
                createRoomViewController.delegate = self
//                createRoomViewController.roomGroup = roomGroup
            }
        }
    }
}

extension MatchingTableViewController: RoomDetailViewControllerDelegate {
    func roomDetailViewController(_ controller: RoomDetailViewController, didFinishAdding item: Room) {
        tableView.reloadData()
    }
}

