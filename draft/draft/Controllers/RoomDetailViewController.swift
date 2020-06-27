//
//  RoomDetailViewController.swift
//  draft
//
//  Created by JSKeum on 2020/05/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

protocol RoomDetailViewControllerDelegate: class {
    func roomDetailViewController(_ controller: RoomDetailViewController, didFinishAdding item: Room)
}

class RoomDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // weak로 순환 참조 방지
    weak var delegate: RoomDetailViewControllerDelegate?
    weak var roomGroup: RoomsByDate?
    
    // '만들기' 누르면 sampleRoom 추가하기
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        roomGroup?.addRoom(room: sampleRoom)
        
        delegate?.roomDetailViewController(self , didFinishAdding: sampleRoom)
    }
}

