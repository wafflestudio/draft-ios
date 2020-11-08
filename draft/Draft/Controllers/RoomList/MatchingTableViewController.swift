//
//  MatchingTableViewController.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class MatchingTableViewController: UITableViewController, UISearchBarDelegate {
    
    internal var roomList = RoomList()
    
    internal var jwtToken = User.shared.jwtToken
    
    @IBAction func sortRoomList(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            sortByRegion()
        case 1:
            sortByDate()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRoomsByRegion()
        
        tableView.register(UINib(nibName: Draft.roomCellNibName, bundle: nil), forCellReuseIdentifier: Draft.roomCellIdentifier)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        #warning("TODO: count에 맞게 section 수 할당")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        #warning("TODO: region / date 분기")
        return roomList.roomsByRegion.rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Draft.roomCellIdentifier, for: indexPath)
        
        if let roomCell = cell as? RoomCell {
            let room = roomList.roomsByRegion.rooms[indexPath.row]
            roomCell.title.text = room.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        #warning("TODO: Region name 할당")
        return "Region"
    }
    
    func sortByRegion() {
        getRoomsByRegion()
    }
    
    func sortByDate() {
        #warning("TODO: Sort rooms by date")
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
