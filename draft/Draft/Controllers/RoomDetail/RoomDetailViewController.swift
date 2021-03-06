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
        print("Create Room viewDidLoad")
        startTimePlaceHolder = startTime.titleLabel?.text
        endTimePlaceHolder = endTime.titleLabel?.text
        
        nameTextField.delegate = self
    }
    
    // weak로 순환 참조 방지
    weak var delegate: RoomDetailViewControllerDelegate?
    
    // room Id from server
    let roomId: Int? = nil
    
    private var startTimePlaceHolder: String?
    private var endTimePlaceHolder: String?
    private var startTimeToAPIRequest: String?
    private var endTimeToAPIRequest: String?
    
    // MARK: - Creating Room through delegate
    @IBAction func done(_ sender: Any) {
        
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
            self.createRoomRequest(startTime: pickedStartTime, endTime: pickedEndTime, name: name, courtId: 1)
        }
        
        self.dismiss(animated: true, completion: {
            self.delegate?.roomDetailViewController(self)
        })
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
    
    // MARK: - IBOutlets - TextField & StartTime & EndTime
    @IBOutlet weak var startTime: UIButton!
    @IBOutlet weak var endTime: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
}

// MARK: - Private Functions used as utility or module
extension RoomDetailViewController {
    
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
        
        print("textField count : \(textField.text?.count)")
        return newLength <= 20
    }
}
