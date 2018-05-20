//
//  TBChatViewController.swift
//  TestChatto
//
//  Created by Nguyen Trong Bang on 20/5/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit

class TBChatViewController: DemoChatViewController {
    var randomMessageTimer: Timer?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        randomMessageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {[weak self] (_) in
            self?.dataSource.addRandomIncomingMessage()
            print("Received new message")
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    private func stopTimer() {
        randomMessageTimer?.invalidate()
        randomMessageTimer = nil
    }
}
