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
    
    internal var userAuth: String?
    internal var createOrDetail: CreateOrDetail?
    internal var roomId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Create Room viewDidLoad")
        
        if (createOrDetail == .create) {
            startTimePlaceHolder = startTime.titleLabel?.text
            endTimePlaceHolder = endTime.titleLabel?.text
        }
        
        if (createOrDetail == .detail) {
            guard let auth = userAuth else {
                print("error: userAuth is nil")
                return
            }
            
            getRoomApiRequest(roomId: roomId!, userAuth: auth) { thisRoom in
                self.setRoomDetailInfo(thisRoom: thisRoom)
            }
        }
        
        nameTextField.delegate = self
    }
    
    // weak로 순환 참조 방지
    weak var delegate: RoomDetailViewControllerDelegate?
    
    
    @IBAction func done(_ sender: Any) {
        if (createOrDetail == .create) {
            createRoom()
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Room Detail
    private var roomName: String?
    private var roomStatus: String?
    private var createAt: String?
    private var startAt: String?
    private var endAt: String?
    private var courdId: Int?
    private var ownerId: Int?
    
    
    // MARK: - Create Room
    private var startTimePlaceHolder: String?
    private var endTimePlaceHolder: String?
    private var startTimeToAPIRequest: String?
    private var endTimeToAPIRequest: String?
    
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
    
    // MARK: - IBOutlets - TextField & StartTime & EndTime
    @IBOutlet weak var startTime: UIButton! {
        didSet {
            if createOrDetail == .detail { startTime.isEnabled = false }
        }
    }
    @IBOutlet weak var endTime: UIButton! {
        didSet {
            if createOrDetail == .detail { endTime.isEnabled = false }
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            if createOrDetail == .detail { nameTextField.isEnabled = false }
        }
    }
    
}

// MARK: - Private Methods used as utility or module
extension RoomDetailViewController {
    
    private func createRoom() {
        guard let name = nameTextField.text else {
            errorAlert(error: .nameEmpty)
            return
        }
        if (name == "") {
            errorAlert(error: .nameEmpty)
            return
        }
        guard let pickedStartTime = startTimeToAPIRequest else {
            errorAlert(error: .startTimeEmpty)
            return
        }
        guard let pickedEndTime = endTimeToAPIRequest else {
            errorAlert(error: .endTimeEmpty)
            return
        }
        
        DispatchQueue.main.async {
            guard let auth = self.userAuth else {
                print("error: userAuth is nil")
                return }
            self.createRoomRequest(startTime: pickedStartTime, endTime: pickedEndTime, name: name, courtId: 1, userAuth: auth)
        }
        
        self.dismiss(animated: true, completion: {
            self.delegate?.roomDetailViewController(self)
        })
    }
    
    private func setRoomDetailInfo(thisRoom: Room?) {
        self.roomName = thisRoom?.name
        self.roomStatus = thisRoom?.roomStatus
        self.createAt = thisRoom?.createdAt
        self.startAt = thisRoom?.startTime
        self.endAt = thisRoom?.endTime
        self.courdId = thisRoom?.courtId
        self.ownerId = thisRoom?.ownerId
        print("after room api : \(String(describing: thisRoom?.startTime))")
        
        self.nameTextField.text = self.roomName
        self.startTime.titleLabel?.text = self.startAt?.timeStringToDateString
        self.endTime.titleLabel?.text = self.endAt?.timeStringToDateString
    }
    
    
    private func errorAlert(error: emptyDateError?) {
        let alert = UIAlertController(title: error?.message(), message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .cancel , handler: nil)
        alert.addAction(action)
        present(alert, animated: false, completion: nil)
    }
    
    enum emptyDateError {
        case startTimeEmpty
        case endTimeEmpty
        case nameEmpty
        
        func message() -> String {
            switch self {
            case .startTimeEmpty:
                return "시작 시간을 정해 주세요"
            case .endTimeEmpty:
                return "종료 시간을 정해 주세요"
            case .nameEmpty:
                return "방 이름을 작성해 주세요"
            }
        }
    }
}

// MARK: - Date Picker Delegate
extension RoomDetailViewController: GameDatePickerViewControllerDelegate {
    func gameDatePickerViewController(_ controller: GameDatePickerViewController, date: Date, type: StartOrEnd) {
        switch type {
        case .startTime:
            startTime.setTitle(date.dateToStringAsYMDHM, for: .normal)
            startTimeToAPIRequest = date.dateToStringAsYMDHMS
            
        case .endTime:
            endTime.setTitle(date.dateToStringAsYMDHM, for: .normal)
            endTimeToAPIRequest = date.dateToStringAsYMDHMS
        }
    }
}

// MARK: - UITextField Delegate
extension RoomDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        
        print("textField count : \(String(describing: textField.text?.count))")
        return newLength <= 20
    }
}

enum CreateOrDetail {
    case create
    case detail
}
