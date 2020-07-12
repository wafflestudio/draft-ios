//
//  RoomDetailViewController.swift
//  draft
//
//  Created by JSKeum on 2020/05/06.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

protocol RoomDetailViewControllerDelegate: class {
    func roomDetailViewController(_ controller: RoomDetailViewController)
}

class RoomDetailViewController: UIViewController {
    
    internal var sampleAuth: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // weak로 순환 참조 방지
    weak var delegate: RoomDetailViewControllerDelegate?
    
    // room Id from server
    let roomId: Int? = nil
    
    // '만들기' 누르면 sampleRoom 추가하기
    @IBAction func done(_ sender: Any) {
        DispatchQueue.main.async {
            self.createRoomReqeust()
        }
        delegate?.roomDetailViewController(self)
        dismiss(animated: true, completion: nil)
    }
}

