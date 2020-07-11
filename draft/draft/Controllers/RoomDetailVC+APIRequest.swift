//
//  RoomDetailVC+APIRequest.swift
//  draft
//
//  Created by JSKeum on 2020/07/11.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import Foundation

extension RoomDetailViewController {
    
    func createRoomReqeust() {
        let url = URL(string: "http://ec2-15-165-158-156.ap-northeast-2.compute.amazonaws.com/api/v1/room/")
        
        let sampleRoomBody = [
            "startTime": "2020-07-08T11:30:00",
            "endTime":  "2020-07-08T13:30:00",
            "name": "종강 기념 플레이",
            "courtId": "1"
        ]
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
                print("httpResponse error")
                return
            }
            
            if (httpResponse.statusCode != 201) {
                print("Request Fail with error \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print(error.debugDescription)
                // data가 nil이 될 때 에러 처리
                return
            }
            
            print("New room created with info : \(data)")
        }
        task.resume()
    }
}
