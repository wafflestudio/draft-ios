//
//  MatchingTableVC+APIRequest.swift
//  draft
//
//  Created by JSKeum on 2020/07/08.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

// MARK:- Call Rest API to get rooms from server
extension MatchingTableViewController {
    func allRoomsAPIRequest() {
        
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
            DispatchQueue.main.async {
                self.parseJSON(roomsData: data)
            }
        }
        task.resume()
    }
    
    func parseJSON(roomsData: Data) {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([Room].self, from: roomsData)
            
            roomGroup = RoomGroup()
            
            roomGroup?.arrangeRoomsByDate(rooms: decodedData)
            
            tableView.reloadData()
            print("parsing completed ")
        } catch {
            // json parse 시 에러 처리
            print(error)
        }
    }
}

// MARK: - API Request for auto login to test RoomVC
extension MatchingTableViewController {
    
    func autoLoginForTest() {
        let url = URL(string: "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/user/signin/")
        
        guard let secret_url = Bundle.main.url(forResource: "../secret_login", withExtension: "json"), let loginInfo = try! String(contentsOf: secret_url).data(using: .utf8) else
        { print("secret_login.json 파일을 불러올 수 없습니다")
            return
        }
        
        var request = URLRequest(url: url!)
        request.httpMethod = "Post"
        request.httpBody = loginInfo
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 204 else {
                    print("HttpResponse Not Succeded with response : \(String(describing: response))")
                    return
            }
            
            if let httpResponse = response as? HTTPURLResponse  {
                if let auth = httpResponse.allHeaderFields["Authentication"] as? String {
                    print(auth)
                    self.sampleAuth = auth
                    self.allRoomsAPIRequest()
                }
                
            } else {
                print("HTTP Response is not correct")
            }
        }
        
        task.resume()
    }
}
