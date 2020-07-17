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
    
    // Room Detail UI 작업 위해 임시로 만든 메소드
    func goToRoomDetailVC()
}

class RoomDetailViewController: UIViewController {
    
    internal var sampleAuth: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create Room viewDidLoad")
    }
    // weak로 순환 참조 방지
    weak var delegate: RoomDetailViewControllerDelegate?
    
    // room Id from server
    let roomId: Int? = nil
    
    // '만들기' 누르면 sampleRoom 추가하기
    @IBAction func done(_ sender: Any) {
        //        DispatchQueue.main.async {
        //            self.createRoomReqeust()
        //        }
        //        delegate?.roomDetailViewController(self)
        dismiss(animated: true, completion: nil)
        
        delegate?.goToRoomDetailVC()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "StartDatePicker" {
            
            if let controller = segue.destination as? GameDatePickerViewController {
                controller.pickerLabelType = .startTime
                controller.delegate = self
            }
            
        } else if segue.identifier == "EndDatePicker" {
            if let controller = segue.destination as? GameDatePickerViewController {
                controller.pickerLabelType = .endTime
                controller.delegate = self
            }
        }
    }
    @IBOutlet weak var startTime: UIButton!
    @IBOutlet weak var endTime: UIButton!
}

// MARK: - Date Picker Delegate
extension RoomDetailViewController: GameDatePickerViewControllerDelegate {
    func gameDatePickerViewController(_ controller: GameDatePickerViewController, date: String, type: StartOrEnd) {
        switch type {
        case .startTime:
            startTime.setTitle(date, for: .normal)
        case .endTime:
            endTime.setTitle(date, for: .normal)
        }
    }
}
