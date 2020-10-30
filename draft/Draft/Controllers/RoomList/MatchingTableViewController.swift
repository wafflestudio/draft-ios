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
    
    internal var jwtToken = User.shared.jwtToken
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchController()
        
        getRoomsByRegion()
        // autoLoginForTest() contains allRoomsAPIRequest()
//        autoLoginForTest()
        
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
}

// MARK: - Navitgation to PopUP : Room Detail View(Create Room, edit Room as well)
extension MatchingTableViewController: RoomDetailViewControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createRoomSegue" {
            if let createRoomViewController = segue.destination as? RoomDetailViewController {
                createRoomViewController.delegate = self
                createRoomViewController.sampleAuth = self.jwtToken
            }
        }
    }
    
    func roomDetailViewController(_ controller: RoomDetailViewController) {
        DispatchQueue.main.async {
            self.getRoomsByRegion()
            self.tableView.reloadData()
        }
    }
}
