//
//  GameDatePickerViewController.swift
//  draft
//
//  Created by JSKeum on 2020/07/18.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

protocol GameDatePickerViewControllerDelegate: class {
    func gameDatePickerViewController(_ controller: GameDatePickerViewController, date: String, type: StartOrEnd)
}

class GameDatePickerViewController: UIViewController {
    
    var pickerLabelType: StartOrEnd?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    weak var delegate: GameDatePickerViewControllerDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var pickerLabel: UILabel! {
        didSet {
            pickerLabel.text = pickerLabelType?.label()
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func choose(_ sender: UIButton) {
        let date = datePicker.date.dateToStringAsYMDHMS
        print(date)
        delegate?.gameDatePickerViewController(self, date: date, type: pickerLabelType!)
        dismiss(animated: true)
    }
}

enum StartOrEnd: String {
    case startTime
    case endTime
    
    func label() -> String {
        switch self {
        case .startTime:
            return "게임 시작 시작을 정해 주세요"
        case .endTime:
            return "게임 종료 시간을 정해 주세요"
        }
    }
}
