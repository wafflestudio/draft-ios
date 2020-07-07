//
//  MatchingTableViewController.swift
//  draft
//
//  Created by JSKeum on 2020/04/26.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class MatchingTableViewController: UITableViewController, UISearchBarDelegate {
    
    private var allRooms: RoomGroup?
    
    private var roomGroup: RoomsByDate?
    
    lazy var numOfSections: Int? = 1 // 나중에 AllRooms class의 count로 수정
    
    required init?(coder: NSCoder) {
        roomGroup = RoomsByDate()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSearchController()
        allRoomsAPIRequest()
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

// MARK:- Call Rest API to get rooms from server
extension MatchingTableViewController {
    func allRoomsAPIRequest() {
        
        let sampleAuth = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1OTQxMTYzNTgsImlhdCI6MTU5NDEwNTM1OCwiZW1haWwiOiJnb2dvZ29AbmF2ZXIuY29tIn0.Z9hm1GmK3a4a0e7MdM7A3_WHg6IhQJdxajC-Ve3H15Y"
        
        let url = URL(string: "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/room/")
        
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sampleAuth, forHTTPHeaderField: "Authentication")
        
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else {
                    // statusCode 200 아닐 때 에러 처리
                    return
            }
            
            guard let data = data else {
                print (error.debugDescription)
                // data가 nil이 될 때 에러 처리
                return
            }
            
            self.parseJSON(roomsData: data)
            
        }
        task.resume()
    }
    
    func parseJSON(roomsData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([Room].self, from: roomsData)
            
            
//            print(decodedData[0].startTime.stringToDate)
            
            allRooms = RoomGroup()
            
            allRooms?.arrangeRoomsByDate(rooms: decodedData)
//            print(allRooms)
        } catch {
            // json parse 시 에러 처리
            print(error)
        }
        
    }
    
}
