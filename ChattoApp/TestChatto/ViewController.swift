//
//  ViewController.swift
//  TestChatto
//
//  Created by Nguyen Trong Bang on 19/5/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(frame: CGRect(x: 100, y: 250, width: 60, height: 60))
        btn.setTitle("Enter chat", for: .normal)
        btn.addTarget(self, action: #selector(gotoChat), for: .touchUpInside)
        btn.backgroundColor = .blue
        view.addSubview(btn)
    }

    @objc func gotoChat() {
        let dataSource = DemoChatDataSource(count: 100, pageSize: 50)
        let viewController = DemoChatViewController()
        viewController.dataSource = dataSource
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

