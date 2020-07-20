//
//  RoomDetailVC+APIRequest.swift
//  draft
//
//  Created by JSKeum on 2020/07/11.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

extension RoomDetailViewController {
    
    func createRoomRequest(startTime: String, endTime: String, name: String, courtId: Int) {
        let url = URL(string: "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/room/")
        
        let sampleRoomBody = [
            "startTime": startTime,
            "endTime":  endTime,
            "name": name,
            "courtId": courtId
            ] as [String : Any]
        
        let data = try? JSONSerialization.data(withJSONObject: sampleRoomBody, options: [])
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(sampleAuth, forHTTPHeaderField: "Authentication")
        request.httpBody = data
        
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("httpResponse error : \(String(describing: error))")
                return
            }
            
            if (httpResponse.statusCode != 201) {
                
                
                print("Request Fail with error \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print(error.debugDescription)
                return
            }
            
            print("New room created with info : \(data)")
        }
        
        task.resume()
    }
}
