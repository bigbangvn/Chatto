//
//  ViewController.swift
//  TestChatto
//
//  Created by Nguyen Trong Bang on 19/5/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn.setTitle("Enter chat", for: .normal)
        btn.addTarget(self, action: #selector(gotoChat), for: .touchUpInside)
        btn.backgroundColor = .blue
        view.addSubview(btn)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btn.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
    }

    @objc func gotoChat() {
        let dataSource = DemoChatDataSource(count: 100, pageSize: 10)
        let viewController = TBDemoChatViewController()
        viewController.dataSource = dataSource
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

