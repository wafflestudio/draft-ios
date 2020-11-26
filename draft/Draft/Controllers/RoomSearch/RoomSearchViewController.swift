//
//  RoomSearchViewController.swift
//  Draft
//
//  Created by 한상현 on 2020/11/18.
//  Copyright © 2020 JSKeum. All rights reserved.
//

import UIKit

class RoomSearchResultCell: UITableViewCell {
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var roomPeopleLabel: UILabel!
    @IBOutlet weak var roomStatusLabel: UILabel!
    @IBOutlet weak var roomCourtLabel: UILabel!
    @IBOutlet weak var roomPlayTimeLabel: UILabel!
    
    
}

class RoomSearchViewController: UIViewController {

    @IBOutlet weak var filterBGView: UIView!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    let viewModel = RoomSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareView()
    }
    
    func prepareView(){
        filterBGView.layer.cornerRadius = 10
        searchResultTableView.layer.cornerRadius = 10
    }
}

extension RoomSearchViewController {
    private func bindTableView() {

        let cities = ["London", "Vienna", "Lisbon"]

//        let citiesOb: Observable<[String]> = Observable.of(cities)
//
//
//
//        citiesOb.bind(to: tableView.rx.items(cellIdentifier: "NameCell")) { (index: Int, element: String, cell: UITableViewCell) in
//
//            cell.textLabel?.text = element
//
//        }.disposed(by: bag)

    }
}
