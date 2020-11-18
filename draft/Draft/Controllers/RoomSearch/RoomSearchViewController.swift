//
//  RoomSearchViewController.swift
//  Draft
//
//  Created by 한상현 on 2020/11/18.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class RoomSearchViewController: UIViewController {

    @IBOutlet weak var filterBGView: UIView!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
        // Do any additional setup after loading the view.
    }
    
    func prepareView(){
        filterBGView.layer.cornerRadius = 10
        searchResultTableView.layer.cornerRadius = 10
    }
}

extension RoomSearchViewController: UITableViewDelegate {
    
}
